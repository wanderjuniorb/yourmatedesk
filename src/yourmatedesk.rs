//! YourMateDesk: identidade e configuração fixa do cliente.
//!
//! O servidor e a chave pública entram na compilação pelas variáveis de ambiente
//! `YMD_SERVER` (ex.: `suporte.exemplo.com.br` ou o IP da VPS) e `YMD_KEY`
//! (conteúdo de `id_ed25519.pub` do servidor). No GitHub Actions elas vêm dos
//! secrets do repositório, então nada fica gravado no código.

use base::config::keys;
use hbb_common::config;

pub const APP_NAME: &str = "YourMateDesk";

const SERVER: Option<&str> = option_env!("YMD_SERVER");
const KEY: Option<&str> = option_env!("YMD_KEY");

/// Aplica o nome e as opções travadas. É chamada antes de qualquer leitura de
/// configuração (pelo `load_custom_client`), em todos os processos: interface,
/// serviço do Windows e gerenciador de conexões.
pub fn apply() {
    *config::APP_NAME.write().unwrap() = APP_NAME.to_owned();

    let server = SERVER.map(str::trim).unwrap_or_default();
    let key = KEY.map(str::trim).unwrap_or_default();

    {
        // "override": o cliente não consegue alterar estes valores.
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
        // Quem acessa pode ajustar as configurações do cliente remotamente.
        settings.insert(
            keys::OPTION_ALLOW_REMOTE_CONFIG_MODIFICATION.to_owned(),
            "Y".to_owned(),
        );
    }

    {
        // Esconde do cliente o que ele não deve mexer.
        let mut builtin = config::BUILTIN_SETTINGS.write().unwrap();
        for k in [
            keys::OPTION_HIDE_SERVER_SETTINGS,
            keys::OPTION_HIDE_NETWORK_SETTINGS,
            keys::OPTION_HIDE_SECURITY_SETTINGS,
            keys::OPTION_HIDE_PROXY_SETTINGS,
            keys::OPTION_HIDE_WEBSOCKET_SETTINGS,
            keys::OPTION_HIDE_STOP_SERVICE,
            keys::OPTION_HIDE_HELP_CARDS,
            keys::OPTION_REMOVE_PRESET_PASSWORD_WARNING,
            // Permite definir a senha fixa pela linha de comando na instalação
            // (`YourMateDesk.exe --password ...`) mesmo com as telas escondidas.
            keys::OPTION_ALLOW_COMMAND_LINE_SETTINGS_WHEN_SETTINGS_DISABLED,
        ] {
            builtin.insert(k.to_owned(), "Y".to_owned());
        }
    }
}
