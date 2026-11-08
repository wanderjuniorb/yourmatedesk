# YourMateDesk

Acesso remoto próprio para suporte aos clientes, baseado no [RustDesk](https://github.com/rustdesk/rustdesk) (AGPL-3.0).

## O que foi personalizado

| Item | Onde |
|---|---|
| Nome do programa (`YourMateDesk`), serviço do Windows, pasta de instalação | `src/yourmatedesk.rs` |
| Servidor e chave fixos (vêm dos secrets `YMD_SERVER` e `YMD_KEY`) | `src/yourmatedesk.rs` |
| Acesso direto só com senha fixa, sem janela de "Aceitar" | `src/yourmatedesk.rs` |
| Configurações de servidor, rede e segurança escondidas do cliente | `src/yourmatedesk.rs` |
| Logo e ícones nas cores do GesCondo | `res/yourmatedesk/make_icons.py` |
| Cor de destaque da interface (#7079F2) | `flutter/lib/common.dart` |
| Dados do arquivo .exe (nome, descrição) | `flutter/windows/runner/Runner.rc` |
| Compilação automática só para Windows x64 | `.github/workflows/yourmatedesk-windows.yml` |
| Escolha **Técnico** ou **Cliente** na instalação (gravada em `ymd-mode.txt`) | `flutter/lib/desktop/pages/install_page.dart`, `src/yourmatedesk.rs` |
| "Minhas conexões" como primeira aba, sem login | `flutter/lib/models/peer_tab_model.dart`, `src/yourmatedesk.rs` |
| Botão de câmera na conexão, salvando em `Imagens\YourMateDesk\<conexão>` | `flutter/lib/desktop/widgets/remote_toolbar.dart`, `flutter/lib/yourmatedesk/screenshot.dart` |

### Modos

- **Técnico** (seu computador): conecta e recebe conexões; mostra a tela de Segurança para definir a senha.
- **Cliente**: só recebe conexões; configurações escondidas. É o padrão do `instalar-cliente.bat` e da instalação silenciosa.

Para trocar o modo de um computador, reinstale escolhendo o outro tipo.

No seu computador, você também pode instalar sem telas com `res/yourmatedesk/instalar-tecnico.bat [SENHA]` (como Administrador).

Os workflows originais do RustDesk foram deixados só para execução manual, para não gastar minutos do GitHub a cada envio.

## 1. Servidor (VPS Ubuntu)

```bash
# instalar o Docker (se ainda não tiver)
curl -fsSL https://get.docker.com | sudo sh

# subir o servidor
mkdir -p ~/yourmatedesk-server && cd ~/yourmatedesk-server
# copie para cá o arquivo res/yourmatedesk/servidor/docker-compose.yml
sudo docker compose up -d

# liberar as portas no firewall
sudo ufw allow 21115:21119/tcp
sudo ufw allow 21116/udp

# chave pública (vai no secret YMD_KEY)
cat ~/yourmatedesk-server/data/id_ed25519.pub
```

Se a VPS tiver firewall no painel do provedor, libere as mesmas portas lá também.
Guarde uma cópia da pasta `data/`: se a chave for perdida, todos os clientes precisam ser reinstalados.

## 2. Secrets no GitHub

Em **Settings → Secrets and variables → Actions → New repository secret**:

- `YMD_SERVER`: IP ou domínio da VPS
- `YMD_KEY`: conteúdo de `id_ed25519.pub`

## 3. Gerar o instalador

**Actions → Build YourMateDesk (Windows) → Run workflow.** Leva por volta de 40 a 60 minutos.
Cada execução cria uma Release `YourMateDesk 1.0.<número>` com `YourMateDesk-x64.exe`. Link fixo da última versão:
https://github.com/wanderjuniorb/yourmatedesk/releases/latest/download/YourMateDesk-x64.exe

A versão em execução aparece na tela principal, abaixo da logo (ex.: *Versão 1.0.12*).

## 4. Instalar

Coloque o instalador junto com o script e dê dois cliques (ele pede permissão de administrador sozinho):

- no seu computador: `res/yourmatedesk/instalar-tecnico.bat`
- nos clientes: `res/yourmatedesk/instalar-cliente.bat`

Depois abra o YourMateDesk e clique em **Definir senha** na tela principal (mínimo 8 caracteres, com maiúscula, minúscula e número). Sem senha definida, ninguém consegue acessar o computador.

## 5. Acessar

No seu computador, instale o mesmo YourMateDesk, digite o ID do cliente e a senha.

## Trocar a logo

Edite as cores e o desenho em `res/yourmatedesk/make_icons.py` e rode `python3 res/yourmatedesk/make_icons.py` na raiz do repositório.

## Licença

Este projeto é uma modificação do RustDesk e continua sob a AGPL-3.0: quem recebe o programa tem direito ao código-fonte modificado (este repositório).
