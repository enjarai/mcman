use std::path::PathBuf;
use clap::{Parser, Subcommand};

#[derive(Parser, Debug)]
#[command(name = "mcman")]
#[command(author = "enjarai")]
#[command(version = "1.0.0")]
#[command(about = "A tool for managing Minecraft servers", long_about = None)]
pub(crate) struct Cli {
    /// Sets a custom java path
    #[arg(short, long, value_name = "FILE", default_value_t = String::from("java"))]
    pub(crate) java: String,

    /// Sets the server directory
    #[arg(short, long, value_name = "DIR")]
    pub(crate) server_dir: Option<PathBuf>,

    // /// Turn debugging information on
    // #[arg(short, long, action = clap::ArgAction::Count)]
    // debug: u8,

    #[command(subcommand)]
    pub(crate) command: Commands,
}

#[derive(Subcommand, Debug)]
pub(crate) enum Commands {
    /// Creates a new server
    Create {
        /// Minecraft version to create a server for
        #[arg(short, long)]
        mc_version: Option<String>,

        /// Skip the EULA prompt
        #[arg(short, long)]
        accept_eula: bool,
    },
}