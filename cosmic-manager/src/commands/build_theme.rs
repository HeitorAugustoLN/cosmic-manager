use crate::commands::Command;
use clap::Args;
use cosmic::{
    cosmic_config::CosmicConfigEntry,
    cosmic_theme::{Theme, ThemeBuilder},
};
use std::io::Error;

#[derive(Args)]
pub struct BuildThemeCommand {}

impl Command for BuildThemeCommand {
    type Err = Error;

    fn execute(&self) -> Result<(), Self::Err> {
        // Get light theme builder from config
        let light_builder = ThemeBuilder::light_config()
            .and_then(|config| {
                Ok(match ThemeBuilder::get_entry(&config) {
                    Ok(builder) => builder,
                    Err((_, builder)) => builder,
                })
            })
            .unwrap_or_else(|_| ThemeBuilder::light());

        // Get dark theme builder from config
        let dark_builder = ThemeBuilder::dark_config()
            .and_then(|config| {
                Ok(match ThemeBuilder::get_entry(&config) {
                    Ok(builder) => builder,
                    Err((_, builder)) => builder,
                })
            })
            .unwrap_or_else(|_| ThemeBuilder::dark());

        // Build themes
        let light_theme = light_builder.build();
        let dark_theme = dark_builder.build();

        // Save light theme
        let light_config = Theme::light_config().map_err(|e| {
            Error::new(
                std::io::ErrorKind::Other,
                format!("Failed to get light theme config: {}", e),
            )
        })?;
        light_theme.write_entry(&light_config).map_err(|e| {
            Error::new(
                std::io::ErrorKind::Other,
                format!("Failed to write light theme: {}", e),
            )
        })?;

        // Save dark theme
        let dark_config = Theme::dark_config().map_err(|e| {
            Error::new(
                std::io::ErrorKind::Other,
                format!("Failed to get dark theme config: {}", e),
            )
        })?;
        dark_theme.write_entry(&dark_config).map_err(|e| {
            Error::new(
                std::io::ErrorKind::Other,
                format!("Failed to write dark theme: {}", e),
            )
        })?;

        println!("Successfully built and saved light and dark themes");
        Ok(())
    }
}
