use std::fs;
use std::io::Write;
use std::path::{Path, PathBuf};
use reqwest::blocking as http;
use serde_json as json;
use serde_json::Value;
use crate::error::Result;
use crate::error::Error::VersionError;

pub(crate) fn get_latest_mc() -> Result<String> {
    println!("Looking up latest Minecraft version...");
    let resp = http::get("https://meta.fabricmc.net/v2/versions/game")?;
    let versions: Value = json::from_str(&resp.text()?)?;
    for version in versions.as_array().unwrap_or(&vec![]) {
        let version = version.as_object().ok_or(VersionError)?;
        let stable = version
            .get("stable").unwrap_or(&Value::Bool(false))
            .as_bool().unwrap_or(false);

        if stable {
            return Ok(String::from(
                version.get("version").ok_or(VersionError)?
                    .as_str().ok_or(VersionError)?
            ));
        }
    }
    Err(VersionError)
}

pub(crate) fn download_file(url: &str, path: &Path, default_name: &str) -> Result<PathBuf> {
    let resp = http::get(url)?;
    let filename = resp
        .headers()
        .get("Content-Disposition")
        .and_then(|disp| disp.to_str().ok())
        .and_then(|disp| disp.split("filename=").nth(1))
        .unwrap_or(default_name).trim_matches('"');
    let filename = PathBuf::from(filename);
    let mut file = fs::File::create(path.join(&filename))?;
    file.write_all(&resp.bytes()?)?;
    Ok(filename)
}

pub(crate) fn prompt_y_n(question: &str) -> Result<bool> {
    let mut input = String::new();
    print!("{} [y/N] ", question);
    std::io::stdout().flush()?;
    std::io::stdin().read_line(&mut input)?;
    Ok(input.trim().to_lowercase() == "y")
}

pub(crate) fn create_eula(eula_path: &Path) -> Result<()> {
    let mut eula_file = fs::File::create(eula_path)?;
    eula_file.write_all(b"eula=true\n")?;
    Ok(())
}
