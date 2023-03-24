use std::io;

pub type Result<T> = std::result::Result<T, Error>;

pub trait ResultExt<T> {
    fn exit_on_err(self) -> T;
}

impl<T> ResultExt<T> for Result<T> {
    fn exit_on_err(self) -> T {
        match self {
            Ok(val) => val,
            Err(err) => {
                eprintln!("Error: {}", err);
                std::process::exit(1);
            }
        }
    }
}

#[derive(Debug)]
pub enum Error {
    HttpError(reqwest::Error),
    JsonError(serde_json::Error),
    IoError(io::Error),
    VersionError,
}

impl std::fmt::Display for Error {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Error::HttpError(err) => write!(f, "HTTP error: {}", err),
            Error::JsonError(err) => write!(f, "JSON error: {}", err),
            Error::IoError(err) => write!(f, "IO error: {}", err),
            Error::VersionError => write!(f, "Could not determine the latest Minecraft version, please specify one manually"),
        }
    }
}

impl From<reqwest::Error> for Error {
    fn from(err: reqwest::Error) -> Self {
        Error::HttpError(err)
    }
}

impl From<serde_json::Error> for Error {
    fn from(err: serde_json::Error) -> Self {
        Error::JsonError(err)
    }
}

impl From<io::Error> for Error {
    fn from(err: io::Error) -> Self {
        Error::IoError(err)
    }
}