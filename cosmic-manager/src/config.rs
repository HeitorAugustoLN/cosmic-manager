// SPDX-License-Identifier: GPL-3.0-only

use etcetera::{
    base_strategy::{BaseStrategy, Xdg},
    choose_base_strategy,
};
use std::{
    fs,
    io::{Error, ErrorKind},
    path::{Path, PathBuf},
};

fn get_base_strategy() -> Result<Xdg, Error> {
    choose_base_strategy().map_err(|e| {
        Error::new(
            ErrorKind::Other,
            format!("Failed to determine base strategy: {}", e),
        )
    })
}

pub fn read_configuration(
    component: &str,
    version: &u64,
    entry: &str,
    xdg_dir: &str,
) -> Result<String, Error> {
    let path = get_configuration_path(component, version, entry, xdg_dir)?;

    if path.exists() {
        fs::read_to_string(path)
    } else {
        Err(Error::new(
            ErrorKind::NotFound,
            format!(
                "Configuration entry not found: {}/v{}/{}",
                component, version, entry
            ),
        ))
    }
}

pub fn parse_configuration_path(path: &Path) -> Option<(String, u64, String)> {
    let parts: Vec<_> = path.iter().collect();

    if parts.len() < 4 {
        return None;
    }

    let entry_name = parts.last()?.to_str()?.to_string();
    let version_str = parts.get(parts.len() - 2)?.to_str()?;
    let version = version_str.strip_prefix('v')?.parse().ok()?;
    let component = parts.get(parts.len() - 3)?.to_str()?.to_string();

    Some((component, version, entry_name))
}

fn get_configuration_path(
    component: &str,
    version: &u64,
    entry: &str,
    xdg_dir: &str,
) -> Result<PathBuf, Error> {
    let cosmic_folder = get_cosmic_configurations(xdg_dir)?;

    Ok(cosmic_folder
        .join(component)
        .join(format!("v{}", version))
        .join(entry))
}

pub fn get_cosmic_configurations(xdg_dir: &str) -> Result<PathBuf, Error> {
    let config_dir = get_xdg_dir_path(xdg_dir)?.join("cosmic");
    Ok(config_dir)
}

pub fn get_xdg_dir_path(xdg_dir: &str) -> Result<PathBuf, Error> {
    match xdg_dir.to_lowercase().as_str() {
        "config" => Ok(get_base_strategy()?.config_dir()),
        "data" => Ok(get_base_strategy()?.data_dir()),
        "cache" => Ok(get_base_strategy()?.cache_dir()),
        "state" => get_base_strategy()?
            .state_dir()
            .ok_or_else(|| Error::new(ErrorKind::NotFound, "State directory is not available")),
        "runtime" => get_base_strategy()?
            .runtime_dir()
            .ok_or_else(|| Error::new(ErrorKind::NotFound, "Runtime directory is not available")),
        _ => Err(Error::new(
            ErrorKind::InvalidInput,
            format!("Invalid XDG directory: {}", xdg_dir),
        )),
    }
}
