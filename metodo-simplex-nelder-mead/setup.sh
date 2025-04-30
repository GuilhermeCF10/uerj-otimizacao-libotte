#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------------
# Configurações
# ------------------------------------------------------------------
ENV_NAME="simplex-nelder-mead"
PY_VERSION="3.12"
OS="$(uname -s)"

# ------------------------------------------------------------------
# Verifica FFmpeg antes de tudo
# ------------------------------------------------------------------
INSTALL_VIDEO_DEPS=0
if command -v ffmpeg >/dev/null 2>&1; then
  echo "✅ ffmpeg detectado no sistema — você já pode usar a flag --save para gerar vídeos MP4."
else
  cat <<'EOF'
❓  Deseja ativar a funcionalidade "--save" (gerar animações em vídeo .mp4)?
   • Isso requer o utilitário **ffmpeg** — um encoder multimídia que o Matplotlib usa
     para transformar quadros em arquivos MP4 comprimidos.
   • Se você responder "sim", o script tentará instalá‑lo automaticamente
     (via apt, Homebrew ou fallback Python).
   (Digite y/N e pressione Enter)
EOF
  read -r REPLY
  REPLY="${REPLY,,}"   # para minúsculas
  if [[ "$REPLY" == "y" || "$REPLY" == "yes" ]]; then
    INSTALL_VIDEO_DEPS=1
  fi
fi

# ------------------------------------------------------------------
# Funções auxiliares
# ------------------------------------------------------------------
install_ffmpeg_system() {
  case "$OS" in
    Darwin)
      if command -v brew >/dev/null 2>&1; then
        brew install ffmpeg
      else
        echo "⚠️  Homebrew não encontrado; instale-o ou deixe que eu use o fallback Python."
        return 1
      fi ;;
    Linux)
      if [[ -f /etc/os-release ]] && grep -qiE 'ubuntu|debian' /etc/os-release; then
        sudo apt-get update && sudo apt-get install -y ffmpeg
      else
        echo "⚠️  Distribuição Linux não suportada automaticamente."
        return 1
      fi ;;
    *)
      echo "⚠️  SO não reconhecido ($OS)."
      return 1 ;;
  esac
}

ensure_video_writer() {
  if command -v ffmpeg >/dev/null 2>&1; then
    echo "✅ ffmpeg disponível no PATH."
    return
  fi
  echo "⚙️  Instalando suporte a vídeo…"
  if install_ffmpeg_system; then
    echo "✅ ffmpeg instalado via gerenciador de pacotes."
    return
  fi
  echo "↳ Instalando fallback Python (imageio-ffmpeg)…"
  pip install --quiet "imageio[ffmpeg]"
  python - <<'PY'
import imageio_ffmpeg, shutil, os, stat, pathlib
bin_path = imageio_ffmpeg.get_ffmpeg_exe()
print(f"✅ ffmpeg estático disponível em {bin_path}")
# cria link simbólico ~/.local/bin/ffmpeg caso não exista no PATH
link = pathlib.Path.home()/".local"/"bin"/"ffmpeg"
link.parent.mkdir(parents=True, exist_ok=True)
if not link.exists():
    link.symlink_to(bin_path)
    st = os.stat(bin_path)
    link.chmod(st.st_mode | stat.S_IXUSR)
    print(f"🔗 Link simbólico criado: {link}")
PY
}

create_conda_env() {
  if ! command -v conda >/dev/null 2>&1; then
    echo "❌ Conda não encontrado no PATH. Instale Miniconda/Anaconda."
    exit 1
  fi
  if conda env list | awk '{print $1}' | grep -qx "$ENV_NAME"; then
    echo "✅ Ambiente \"$ENV_NAME\" já existe."
  else
    echo "⚙️  Criando ambiente Conda \"$ENV_NAME\"…"
    conda create -y -n "$ENV_NAME" "python=$PY_VERSION"
  fi
}

activate_env_and_run() {
  eval "$(conda shell.bash hook)"
  conda activate "$ENV_NAME"

  echo "⚙️  Instalando dependências Python…"
  pip install -r requirements.txt

  if [[ $INSTALL_VIDEO_DEPS -eq 1 ]]; then
    ensure_video_writer
  fi

  echo "🚀 Executando main.py…"
  python3 main.py
}

# ------------------------------------------------------------------
# Execução principal
# ------------------------------------------------------------------
create_conda_env
activate_env_and_run
