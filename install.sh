#! /bin/bash

ln -sf $PWD/.zshrc ~/.zshrc
ln -sf $PWD/.p10k.zsh ~/.p10k.zsh
ln -sf $PWD/.shell_aliases ~/.shell_aliases
ln -sf $PWD/.macosrc ~/.macosrc

./dotnet-install.sh -c 6.0
./dotnet-install.sh --runtime dotnet -c 6.0
./dotnet-install.sh --runtime aspdotnetcore -c 6.0

./dotnet-install.sh -c 8.0
./dotnet-install.sh --runtime dotnet -c 8.0
./dotnet-install.sh --runtime aspdotnetcore -c 8.0
