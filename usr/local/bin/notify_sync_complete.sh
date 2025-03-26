#!/bin/bash


# Hector Vido Silva e Fernando Souza

# Data: 25/03/2025 as 22:24:39

# https://github.com/tuxslack/notify_sync


# Saber quanto tempo o sync demorará.



# Dica aleatória:

# Cansado de saber quanto tempo demorará para o "sync" terminar e podermos finalmente 
# remover o pendrive sem corromper o que está sendo copiado?

# Dê um "cat /proc/meminfo" e procure pela linha "dirty". Ela representa os dados em 
# memória que ainda não foram enviadas para o disco - neste caso ~1.6GB.

# Essa área faz parte daquele "buff/cache" que vemos ao executamos "free".


# Caso de uso:

# Queria ter visto essa dica uma semana atrás, quando corrompi toda uma copia ao remover o pendrive kkkkkkk


# https://www.linkedin.com/posts/hectorvido_linux-opensource-shell-activity-7307103238019780608-MH2d?utm_source=social_share_send&utm_medium=member_desktop_web&rcm=ACoAABz8zocBPtpnfQaeYybvNrE0EZZNaARCQZY

# ----------------------------------------------------------------------------------------


# Para notificar o usuário quando a escrita de dados no disco terminar. O script irá 
# monitorar a linha "Dirty" em /proc/meminfo e notificará o usuário quando o valor de 
# "Dirty" for igual a zero, indicando que todos os dados foram gravados no disco.


# Torne o script executável:

# chmod +x notify_sync_complete.sh

# vExecute o script:

# ./notify_sync_complete.sh





clear


# Função para verificar se os pacotes estão instalados

check_requirements() {

    # Lista dos comandos que queremos verificar

    required_commands=("notify-send" "wmctrl" "xterm" "grep" "awk" "date")

    # Verifica cada comando

    for cmd in "${required_commands[@]}"; do

        if ! command -v "$cmd" &> /dev/null; then

            echo "Erro: O comando '$cmd' não está instalado. Instale-o antes de continuar."

            exit 1
        fi

    done
}




# Função para obter o valor de "Dirty" de /proc/meminfo

get_dirty_value() {

    grep -i dirty /proc/meminfo | awk '{print $2}'

}


# Função para exibir uma notificação no terminal

notify_user() {

# Para verificar se o sistema está utilizando um ambiente gráfico ou um gerenciador de 
# janelas (window manager), e assim decidir se o comando notify-send pode ser usado, podemos 
# testar se uma variável de ambiente relacionada a um ambiente gráfico (como DISPLAY) está 
# configurada. Se estiver, isso indica que o sistema está em um ambiente gráfico. Caso 
# contrário, podemos optar por não usar o notify-send.

# A variável DISPLAY é uma variável de ambiente que é configurada automaticamente em 
# ambientes gráficos (como X11 ou Wayland). Se essa variável estiver configurada 
# (não vazia), podemos assumir que o sistema está em um ambiente gráfico, permitindo o 
# uso de notify-send para exibir notificações.


    # Verifica se está no ambiente gráfico (variável DISPLAY está configurada)

    if [ -n "$DISPLAY" ]; then

        echo -e "\n[$(date)] - A escrita de dados no disco foi concluída! Você pode remover o pendrive com segurança.\n"

        # O comando notify-send pode não funcionar se o ambiente gráfico não estiver disponível (como em servidores sem interface gráfica).

        notify-send "A escrita de dados no disco foi concluída!" "Você pode remover o pendrive com segurança."

    else

        # Caso não esteja no ambiente gráfico, apenas exibe no terminal

        echo "A escrita de dados no disco foi concluída! Você pode remover o pendrive com segurança."
    fi


}



# Função para obter a resolução do monitor

get_screen_resolution() {

    # Usa o xrandr para obter a resolução da tela primária (a primeira tela detectada)

    resolution=$(xrandr | grep '*' | awk '{print $1}' | head -n 1)

    echo "$resolution"

}


# Função para centralizar o xterm na tela

center_xterm() {

    # Espera a janela do xterm abrir

    sleep 1

    # Obtém a resolução da tela

    screen_resolution=$(get_screen_resolution)
    
    # Divide a resolução em largura e altura

    width=$(echo $screen_resolution | cut -d 'x' -f 1)
    height=$(echo $screen_resolution | cut -d 'x' -f 2)

    # Calcula a posição para centralizar a janela (considerando a resolução do xterm de 800x600)

    x_pos=$(( (width - 800) / 2 ))
    y_pos=$(( (height - 600) / 2 ))

    # echo "$x_pos x $y_pos"


    # Usa wmctrl para mover a janela para a posição calculada

    wmctrl -r "Monitor de Dirty" -e 0,$x_pos,$y_pos,800,600



}


# Verifica se todos os pacotes necessários estão instalados

check_requirements


# ----------------------------------------------------------------------------------------

modo_grafico(){

# Abre uma janela do xterm para exibir o valor de dirty, lendo diretamente de /proc/meminfo

xterm -T "Monitor de Dirty" -e "while true; do

    dirty_value=\$(grep -i dirty /proc/meminfo | awk '{print \$2}')

    echo 'Valor de dirty: '\$dirty_value''

    sleep 5

done" &


# Captura o PID do xterm aberto
xterm_pid=$!


# Espera um pouco para garantir que o xterm tenha sido aberto

center_xterm


}


# modo_grafico


# ----------------------------------------------------------------------------------------



# Loop para verificar se a escrita de dados terminou

while true; do

    dirty_value=$(get_dirty_value)

    # Verifica se o valor retornado é um número

    if ! [[ "$dirty_value" =~ ^[0-9]+$ ]]; then

        echo "Erro: o valor de dirty não é numérico. Verifique /proc/meminfo."

        exit 1
    fi


    echo "Valor de dirty: $dirty_value"

    # Verifica se a linha Dirty está com valor 0

    if [ "$dirty_value" -eq 0 ]; then

        notify_user

        break  # Sai do loop quando a escrita for concluída

    fi



    # Aguarda 5 segundos antes de verificar novamente

    sleep 5




    # Verifica se o xterm foi fechado (verificando o PID) - Somente para modo grafico verifica se a função modo_grafico esta ativa para desativar o if abaixo

    # if ! kill -0 $xterm_pid 2>/dev/null; then

    #    echo -e "\nO xterm foi fechado. Encerrando o script.\n"

    #    break  # Sai do loop caso o xterm seja fechado

    # fi



done



exit 0

