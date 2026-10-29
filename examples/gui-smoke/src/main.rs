use adw::prelude::*;
use std::cell::Cell;

fn main() -> gtk::glib::ExitCode {
    let app = adw::Application::builder()
        .application_id("io.github.mglolenstine.Gtk4CrossSmoke")
        .build();
    app.connect_activate(build_window);
    app.run()
}

fn build_window(app: &adw::Application) {
    let gtk_version = format!(
        "{}.{}.{}",
        gtk::major_version(),
        gtk::minor_version(),
        gtk::micro_version()
    );
    let adw_version = format!(
        "{}.{}.{}",
        adw::major_version(),
        adw::minor_version(),
        adw::micro_version()
    );
    let title = format!("GTK {gtk_version} / libadwaita {adw_version}");
    let window = adw::ApplicationWindow::builder()
        .application(app)
        .title(&title)
        .default_width(500)
        .default_height(360)
        .build();

    let layout = gtk::Box::new(gtk::Orientation::Vertical, 0);
    layout.append(&adw::HeaderBar::new());

    let content = gtk::Box::new(gtk::Orientation::Vertical, 16);
    content.set_margin_top(24);
    content.set_margin_bottom(24);
    content.set_margin_start(32);
    content.set_margin_end(32);
    let heading = gtk::Label::new(Some("Rust GTK4 cross-compilation"));
    heading.add_css_class("title-2");
    content.append(&heading);
    content.append(&gtk::Label::new(Some(&title)));

    let name = gtk::Entry::builder()
        .placeholder_text("Enter your name")
        .build();
    content.append(&name);
    let greet = gtk::Button::with_label("Say hello");
    greet.add_css_class("suggested-action");
    content.append(&greet);
    let response = gtk::Label::new(Some("Ready — type a name and click Say hello."));
    response.set_wrap(true);
    content.append(&response);
    let count = Cell::new(0u32);
    greet.connect_clicked(move |_| {
        let next = count.get() + 1;
        count.set(next);
        let text = name.text();
        let name = if text.trim().is_empty() {
            "world"
        } else {
            text.trim()
        };
        let message = format!("Hello, {name}! Clicks: {next}");
        response.set_label(&message);
        println!("GUI_ACTION {message}");
    });

    layout.append(&content);
    window.set_content(Some(&layout));
    window.present();
    println!("GUI_READY {title}");
}
