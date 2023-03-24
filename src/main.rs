use std::fs::File;
use std::io::Write;
use clap::Parser;
use crate::args::Commands::*;
use crate::error::{Error, ResultExt};
use crate::operations::create::*;

mod args;
mod error;
mod operations;

const SANE_SERVER_PROPERTIES: &str = r#"#Minecraft server properties
motd=A Minecraft Server
server-port=25565
difficulty=normal
level-seed=
white-list=false
enforce-whitelist=false
enable-command-block=true
allow-flight=true
spawn-protection=0
"#;

fn main() {
    let exe_name = std::env::args().next().unwrap_or("mcman".to_string());
    let args = args::Cli::parse();

    let java_path = args.java;
    let server_dir = args.server_dir.unwrap_or_else(|| std::env::current_dir().unwrap());

    match args.command {
        Create { mc_version, accept_eula } => {
            let mc_version = mc_version.unwrap_or_else(|| get_latest_mc().exit_on_err());
            println!("Creating server for Minecraft version {} in '{}'", mc_version, server_dir.display());

            println!("Downloading server jar");
            let server_jar = download_file(
                &format!("https://meta.fabricmc.net/v2/versions/loader/{}/stable/stable/server/jar", mc_version),
                &server_dir, "server.jar"
            ).exit_on_err();
            println!("Downloaded server jar to '{}'", server_jar.display());

            println!("Creating start script");
            let start_sh = server_dir.join("start.sh");
            let mut start_sh_file = File::create(&start_sh).map_err(Error::IoError).exit_on_err();
            start_sh_file.write_all(format!(
                "#!/bin/sh\n{} -Xms1024M -Xmx2048M -jar '{}' nogui\n", java_path, server_jar.display()
            ).as_bytes()).map_err(Error::IoError).exit_on_err();

            println!("Creating default server.properties");
            let server_properties = server_dir.join("server.properties");
            if !server_properties.exists() {
                let mut server_properties_file = File::create(&server_properties).map_err(Error::IoError).exit_on_err();
                server_properties_file.write_all(SANE_SERVER_PROPERTIES.as_bytes()).map_err(Error::IoError).exit_on_err();
            }

            let eula_path = server_dir.join("eula.txt");
            if !eula_path.exists() {
                if accept_eula || prompt_y_n("Do you accept the Minecraft EULA?").unwrap_or(false) {
                    create_eula(&eula_path).exit_on_err();
                }
            }

            println!("Done! Use '{} start' to start the server.", exe_name);
        },
    }
}
