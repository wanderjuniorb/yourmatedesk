//! YourMateDesk: identidade e configuração fixa do cliente.
//!
//! O servidor e a chave pública entram na compilação pelas variáveis de ambiente
//! `YMD_SERVER` (ex.: `suporte.exemplo.com.br` ou o IP da VPS) e `YMD_KEY`
//! (conteúdo de `id_ed25519.pub` do servidor). No GitHub Actions elas vêm dos
//! secrets do repositório, então nada fica gravado no código.
//!
//! Modos (escolhidos na instalação e gravados em `ymd-mode.txt` na pasta de
//! instalação, que só um administrador pode alterar):
//! - `tech`   (Técnico): conecta e recebe conexões, tela de segurança visível.
//! - `client` (Cliente): só recebe conexões, configurações escondidas.

use base::config::keys;
use hbb_common::config;

pub const APP_NAME: &str = "YourMateDesk";
pub const MODE_FILE: &str = "ymd-mode.txt";
/// Palavras usadas nas opções de instalação (`install_me`).
pub const INSTALL_OPTION_TECH: &str = "ymd-tech";
pub const INSTALL_OPTION_CLIENT: &str = "ymd-client";

/// Versão do YourMateDesk mostrada no programa: `<base>.<número da compilação>`.
/// O número vem de `YMD_BUILD` (no GitHub Actions, o número da execução).
pub const VERSION_BASE: &str = "1.0";
const BUILD: Option<&str> = option_env!("YMD_BUILD");

pub fn version() -> String {
    format!(
        "{}.{}",
        VERSION_BASE,
        BUILD
            .map(str::trim)
            .filter(|b| !b.is_empty())
            .unwrap_or("0")
    )
}

/// Texto exibido na tela principal, ex.: "Versão 1.0.12 · compilado em 2026-11-08 23:10".
pub fn version_text() -> String {
    format!("Versão {} · compilado em {}", version(), crate::BUILD_DATE)
}

const SERVER: Option<&str> = option_env!("YMD_SERVER");
const KEY: Option<&str> = option_env!("YMD_KEY");

#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum Mode {
    Tech,
    Client,
}

fn parse_mode(text: &str) -> Option<Mode> {
    match text.trim().to_lowercase().as_str() {
        "tech" => Some(Mode::Tech),
        "client" => Some(Mode::Client),
        _ => None,
    }
}

fn read_mode_in(dir: &std::path::Path) -> Option<Mode> {
    std::fs::read_to_string(dir.join(MODE_FILE))
        .ok()
        .and_then(|s| parse_mode(&s))
}

/// Descobre o modo: primeiro ao lado do executável em uso, depois na pasta onde
/// o YourMateDesk está instalado. Sem instalação (só o instalador aberto), usa
/// o modo Técnico para mostrar a tela completa e a tela de instalação.
pub fn mode() -> Mode {
    if let Some(dir) = std::env::current_exe()
        .ok()
        .and_then(|p| p.parent().map(|d| d.to_path_buf()))
    {
        if let Some(m) = read_mode_in(&dir) {
            return m;
        }
    }
    #[cfg(windows)]
    {
        let (_, path, _, _) = crate::platform::get_install_info();
        if !path.is_empty() {
            if let Some(m) = read_mode_in(std::path::Path::new(&path)) {
                return m;
            }
            // Instalado por uma versão antiga, sem o arquivo: trata como cliente.
            if crate::platform::is_installed() {
                return Mode::Client;
            }
        }
    }
    Mode::Tech
}

/// Valor gravado em `ymd-mode.txt` conforme as opções de instalação.
/// Sem escolha explícita (ex.: `--silent-install` do instalar-cliente.bat),
/// instala como Cliente.
pub fn mode_for_install_options(options: &str) -> &'static str {
    if options.contains(INSTALL_OPTION_TECH) {
        "tech"
    } else {
        "client"
    }
}

/// Aplica o nome e as opções travadas. É chamada antes de qualquer leitura de
/// configuração (pelo `load_custom_client`), em todos os processos: interface,
/// serviço do Windows e gerenciador de conexões.
pub fn apply() {
    *config::APP_NAME.write().unwrap() = APP_NAME.to_owned();
    let mode = mode();

    let server = SERVER.map(str::trim).unwrap_or_default();
    let key = KEY.map(str::trim).unwrap_or_default();

    {
        // "override": ninguém consegue alterar estes valores.
        let mut settings = config::OVERWRITE_SETTINGS.write().unwrap();
        if !server.is_empty() {
            settings.insert(
                keys::OPTION_CUSTOM_RENDEZVOUS_SERVER.to_owned(),
                server.to_owned(),
            );
            settings.insert(keys::OPTION_RELAY_SERVER.to_owned(), server.to_owned());
        }
        if !key.is_empty() {
            settings.insert(keys::OPTION_KEY.to_owned(), key.to_owned());
        }
        // Acesso direto: só senha fixa, sem janela de "Aceitar".
        settings.insert(keys::OPTION_APPROVE_MODE.to_owned(), "password".to_owned());
        settings.insert(
            keys::OPTION_VERIFICATION_METHOD.to_owned(),
            "use-permanent-password".to_owned(),
        );
        // Quem acessa pode ajustar as configurações do computador remotamente.
        settings.insert(
            keys::OPTION_ALLOW_REMOTE_CONFIG_MODIFICATION.to_owned(),
            "Y".to_owned(),
        );
    }

    {
        let mut hard = config::HARD_SETTINGS.write().unwrap();
        // Sem conta/login nem catálogo de endereços do servidor Pro:
        // as conexões ficam salvas no próprio computador (Minhas conexões).
        hard.insert("disable-account".to_owned(), "Y".to_owned());
        if mode == Mode::Client {
            // Cliente só recebe conexões.
            hard.insert("conn-type".to_owned(), "incoming".to_owned());
        }
    }

    {
        let mut builtin = config::BUILTIN_SETTINGS.write().unwrap();
        // Escondido nos dois modos (já é fixo pelo código).
        let mut hide = vec![
            keys::OPTION_HIDE_SERVER_SETTINGS,
            keys::OPTION_HIDE_PROXY_SETTINGS,
            keys::OPTION_HIDE_WEBSOCKET_SETTINGS,
            keys::OPTION_HIDE_HELP_CARDS,
            keys::OPTION_REMOVE_PRESET_PASSWORD_WARNING,
            // Permite definir a senha pela linha de comando na instalação
            // (`YourMateDesk.exe --password ...`).
            keys::OPTION_ALLOW_COMMAND_LINE_SETTINGS_WHEN_SETTINGS_DISABLED,
        ];
        if mode == Mode::Client {
            // No cliente, esconde também segurança, rede e o botão de parar.
            hide.extend([
                keys::OPTION_HIDE_NETWORK_SETTINGS,
                keys::OPTION_HIDE_SECURITY_SETTINGS,
                keys::OPTION_HIDE_STOP_SERVICE,
            ]);
        }
        for k in hide {
            builtin.insert(k.to_owned(), "Y".to_owned());
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn install_options_default_to_client() {
        assert_eq!(mode_for_install_options("desktopicon startmenu"), "client");
        assert_eq!(mode_for_install_options(" startmenu ymd-client"), "client");
        assert_eq!(mode_for_install_options(" startmenu ymd-tech"), "tech");
    }

    #[test]
    fn parse_mode_file() {
        assert_eq!(parse_mode("tech\r\n"), Some(Mode::Tech));
        assert_eq!(parse_mode(" client "), Some(Mode::Client));
        assert_eq!(parse_mode("x"), None);
    }
}
