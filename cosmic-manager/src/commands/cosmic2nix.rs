// SPDX-License-Identifier: GPL-3.0-only

use crate::{
    commands::Command,
    config::{get_cosmic_configurations, parse_configuration_path, read_configuration},
    utils::escape_string,
};
use clap::Args;
use fancy_regex::Regex;
use std::{collections::HashMap, fs, io::Error, path::PathBuf};
use walkdir::WalkDir;

#[derive(Args)]
pub struct Cosmic2NixCommand {
    /// The XDG directories to search for COSMIC configurations.
    #[arg(short, long, value_delimiter = ',', default_value = "config,state")]
    xdg_dirs: Vec<String>,

    output_file: Option<PathBuf>,
}

struct ComponentData {
    version: u64,
    entries: HashMap<String, String>,
}

impl Command for Cosmic2NixCommand {
    type Err = Error;

    fn execute(&self) -> Result<(), Self::Err> {
        let mut output = String::new();

        output.push_str("{ cosmicLib, ... }:\n");
        output.push_str("{\n");
        output.push_str("  wayland.desktopManager.cosmic = {\n");
        output.push_str("    enable = true;\n");

        for xdg_dir in &self.xdg_dirs {
            let cosmic_path = get_cosmic_configurations(xdg_dir)?;
            let mut components: HashMap<String, ComponentData> = HashMap::new();

            output.push_str(&format!("    {}File = {{\n", xdg_dir));

            for entry in WalkDir::new(&cosmic_path)
                .into_iter()
                .filter_map(|e| e.ok())
                .filter(|e| e.file_type().is_file())
            {
                if let Some((component, version, entry_name)) =
                    parse_configuration_path(entry.path())
                {
                    match read_configuration(&component, &version, &entry_name, xdg_dir) {
                        Ok(content) => {
                            components
                                .entry(component.clone())
                                .or_insert_with(|| ComponentData {
                                    version,
                                    entries: HashMap::new(),
                                })
                                .entries
                                .insert(entry_name, content);
                        }
                        Err(e) => {
                            eprintln!("Failed to read configuration: {}", e);
                        }
                    }
                }
            }

            for (component_name, component_data) in components {
                output.push_str(&format!("      \"{}\" = {{\n", component_name));
                output.push_str(&format!("        version = {};\n", component_data.version));
                output.push_str("        entries = {\n");

                let mut formatted_entries = String::new();
                for (entry_name, content) in component_data.entries {
                    formatted_entries.push_str(&to_nix_expression(
                        Some(&entry_name),
                        &content,
                        "          ",
                        None,
                    ));
                }
                output.push_str(&formatted_entries);

                output.push_str("        };\n");
                output.push_str("      };\n");
            }

            output.push_str("    };\n");
        }
        output.push_str("  };\n");
        output.push_str("}\n");

        match &self.output_file {
            Some(path) => {
                fs::write(path, output)?;
                println!("Wrote COSMIC configuration to {}", path.display());
            }
            None => {
                println!("{}", output);
            }
        }

        Ok(())
    }
}

fn to_nix_expression(
    entry: Option<&str>,
    input: &str,
    indent: &str,
    prev_type: Option<&str>,
) -> String {
    let bool_pattern = Regex::new(r"^(true|false)$").unwrap();
    let char_pattern = Regex::new(r"^'\w'$").unwrap();
    let float_pattern = Regex::new(r"^-?\d+\.\d+$").unwrap();
    let int_pattern = Regex::new(r"^-?\d+$").unwrap();
    let none_pattern = Regex::new(r"^None$").unwrap();
    let some_pattern = Regex::new(r#"^Some\((.*)\)$"#).unwrap();
    let str_pattern = Regex::new(r#"^".*"$"#).unwrap();

    let escaped_input = if let Some(_) = prev_type {
        input.to_string()
    } else {
        escape_string(input)
    };

    let format_with_entry = |value: String| -> String {
        match entry {
            Some(e) => format!("{}{} = {};\n", indent, e, value),
            None => value,
        }
    };

    let wrap_value = |value: String| -> String {
        match prev_type {
            None => value,
            _ => format!("({})", value),
        }
    };

    let process_some_value = |inner: &str| -> String {
        let inner_value = inner.trim();
        // Recursively process the inner value
        let processed_inner = to_nix_expression(None, inner_value, indent, Some("optional"));
        format!(
            "cosmicLib.cosmic.mkRon \"optional\" {}",
            processed_inner.trim()
        )
    };

    if let Ok(Some(captures)) = some_pattern.captures(&escaped_input) {
        if let Some(inner) = captures.get(1) {
            format_with_entry(wrap_value(process_some_value(inner.as_str())))
        } else {
            format_with_entry(wrap_value(format!(
                "cosmicLib.cosmic.mkRon \"optional\" null"
            )))
        }
    } else if bool_pattern.is_match(input).unwrap_or(false)
        || float_pattern.is_match(input).unwrap_or(false)
        || int_pattern.is_match(input).unwrap_or(false)
    {
        format_with_entry(escaped_input)
    } else if char_pattern.is_match(input).unwrap_or(false) {
        format_with_entry(wrap_value(format!(
            "cosmicLib.cosmic.mkRon \"char\" \"{}\"",
            escaped_input
        )))
    } else if none_pattern.is_match(input).unwrap_or(false) {
        format_with_entry(wrap_value(
            "cosmicLib.cosmic.mkRon \"optional\" null".to_string(),
        ))
    } else if str_pattern.is_match(input).unwrap_or(false) {
        format_with_entry(format!("\"{}\"", escaped_input))
    } else {
        format_with_entry(wrap_value(format!(
            "cosmicLib.cosmic.mkRon \"raw\" \"{}\"",
            escaped_input
        )))
    }
}
