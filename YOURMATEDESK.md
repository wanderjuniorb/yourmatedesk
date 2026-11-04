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
O arquivo `YourMateDesk-<versão>-x64.exe` fica nos artefatos da execução e na Release `yourmatedesk-latest`.

## 4. Instalar no cliente

Copie para o computador do cliente o instalador e `res/yourmatedesk/instalar-cliente.bat`, e rode **como Administrador**:

```
instalar-cliente.bat SenhaForteDoCliente
```

O script instala, define a senha fixa e mostra o ID. Use uma senha diferente e forte para cada cliente.

## 5. Acessar

No seu computador, instale o mesmo YourMateDesk, digite o ID do cliente e a senha.

## Trocar a logo

Edite as cores e o desenho em `res/yourmatedesk/make_icons.py` e rode `python3 res/yourmatedesk/make_icons.py` na raiz do repositório.

## Licença

Este projeto é uma modificação do RustDesk e continua sob a AGPL-3.0: quem recebe o programa tem direito ao código-fonte modificado (este repositório).
