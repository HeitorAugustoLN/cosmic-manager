// SPDX-License-Identifier: GPL-3.0-only

mod commands;
mod config;
mod utils;

use crate::commands::Commands;
use clap::Parser;

#[derive(Parser)]
#[command(author, version, about, long_about = None)]
#[command(propagate_version = true)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

fn main() {
    let cli = Cli::parse();

    let cmd = cli.command;
    if let Err(e) = cmd.execute() {
        eprintln!("Error: {}", e);
        std::process::exit(1);
    }
}
