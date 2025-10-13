use serde_json::json;
use std::error::Error;
use std::fs;
use std::path::Path;
use syn::{Item, ItemEnum, parse_file};

const GITHUB_API_TAGS: &str = "https://api.github.com/repos/pop-os/cosmic-settings-daemon/tags";
const ACTION_RS_PATH: &str = "config/src/shortcuts/action.rs";
const OUTPUT_FILE: &str = "data/shortcut-actions.json";

fn main() -> Result<(), Box<dyn Error>> {
    let client = reqwest::blocking::Client::builder()
        .user_agent("shortcut-actions-generator")
        .build()?;

    let response = client.get(GITHUB_API_TAGS).send()?;
    let tags: Vec<serde_json::Value> = response.json()?;

    let latest_tag = tags
        .first()
        .and_then(|t| t["name"].as_str())
        .ok_or("No tags found")?;

    eprintln!("Using tag: {}", latest_tag);

    let action_rs_url = format!(
        "https://raw.githubusercontent.com/pop-os/cosmic-settings-daemon/{}/{}",
        latest_tag, ACTION_RS_PATH
    );

    let response = client.get(&action_rs_url).send()?;
    let source_code = response.text()?;

    let syntax_tree = parse_file(&source_code)?;

    let mut all_enums = Vec::new();

    for item in syntax_tree.items {
        if let Item::Enum(enum_item) = item {
            let enum_data = parse_enum(&enum_item);
            all_enums.push(enum_data);
        }
    }

    let output = json!({
        "enums": all_enums,
        "source_url": action_rs_url,
        "tag": latest_tag
    });

    let json_string = serde_json::to_string_pretty(&output)?;

    // Create data directory if it doesn't exist
    if let Some(parent) = Path::new(OUTPUT_FILE).parent() {
        fs::create_dir_all(parent)?;
    }

    // Write to file
    fs::write(OUTPUT_FILE, &json_string)?;
    eprintln!("JSON written to {}", OUTPUT_FILE);

    Ok(())
}

fn parse_enum(enum_item: &ItemEnum) -> serde_json::Value {
    let enum_name = enum_item.ident.to_string();
    let mut variants = Vec::new();

    for variant in &enum_item.variants {
        let variant_name = variant.ident.to_string();

        let fields = match &variant.fields {
            syn::Fields::Unit => json!(null),
            syn::Fields::Unnamed(fields) => {
                let field_types: Vec<String> = fields
                    .unnamed
                    .iter()
                    .map(|f| {
                        let ty = &f.ty;
                        quote::quote!(#ty).to_string()
                    })
                    .collect();
                json!(field_types)
            }
            syn::Fields::Named(fields) => {
                let field_info: Vec<_> = fields
                    .named
                    .iter()
                    .map(|f| {
                        let ty = &f.ty;
                        json!({
                            "name": f.ident.as_ref().unwrap().to_string(),
                            "type": quote::quote!(#ty).to_string()
                        })
                    })
                    .collect();
                json!(field_info)
            }
        };

        let is_deprecated = variant
            .attrs
            .iter()
            .any(|attr| attr.path().is_ident("deprecated"));

        variants.push(json!({
            "name": variant_name,
            "fields": fields,
            "deprecated": is_deprecated
        }));
    }

    json!({
        "name": enum_name,
        "variants": variants
    })
}
