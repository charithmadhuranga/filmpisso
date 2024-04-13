use tokio_with_wasm::tokio;

mod imagecrop;
mod messages;

rinf::write_interface!();

/// This `hub` crate is the entry point for the Rust logic.
/// Always use non-blocking async functions such as `tokio::fs::File::open`.
async fn main() {
    // Repeat `crate::spawn` anywhere in your code
    // if more concurrent tasks are needed.
    tokio::spawn(imagecrop::start_croping());
}
