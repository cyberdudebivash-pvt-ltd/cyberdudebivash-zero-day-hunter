use tauri::Manager;

#[tauri::command]
fn start_hunt() -> String {
    "Zero-Day Hunt Started — Sovereign Mode".to_string()
}

fn main() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![start_hunt])
        .run(tauri::generate_context!())
        .expect("error running Tauri app");
}