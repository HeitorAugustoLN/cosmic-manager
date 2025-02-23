// SPDX-License-Identifier: GPL-3.0-only

mod build_theme;
mod cosmic2nix;

use crate::commands::{build_theme::BuildThemeCommand, cosmic2nix::Cosmic2NixCommand};
use clap::Subcommand;
use std::io::Error;

#[derive(Subcommand)]
pub enum Commands {
    /// Manually build light and dark themes using builder settings.
    BuildTheme(BuildThemeCommand),
    /// Convert your COSMIC configurations to cosmic-manager configuration.
    #[clap(name = "cosmic2nix")]
    Cosmic2Nix(Cosmic2NixCommand),
}

impl Commands {
    pub(crate) fn execute(&self) -> Result<(), Error> {
        match self {
            Commands::BuildTheme(cmd) => cmd.execute(),
            Commands::Cosmic2Nix(cmd) => cmd.execute(),
        }
    }
}

pub trait Command {
    type Err;

    fn execute(&self) -> Result<(), Self::Err>;
}
