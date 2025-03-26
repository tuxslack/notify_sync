## Notify Sync

Cansado de não saber quanto tempo falta para o processo de sync terminar 
e poder finalmente remover o pendrive sem correr o risco de corromper os 
dados que estão sendo copiados?

Este script monitora os dados em memória que ainda não foram enviados para 
o disco. Esses dados fazem parte da área 'buff/cache', que pode ser observada 
ao executar o comando free.

O objetivo é notificar o usuário quando a escrita de dados no disco for 
concluída. O script monitora a linha 'Dirty' em /proc/meminfo e envia uma 
notificação quando o valor de 'Dirty' atingir zero, indicando que todos os 
dados foram gravados no disco.

![](https://github.com/tuxslack/notify_sync/blob/master/3.jpeg)
![](https://github.com/tuxslack/notify_sync/blob/master/0.png)
![](https://github.com/tuxslack/notify_sync/blob/master/1.png)
![](https://github.com/tuxslack/notify_sync/blob/master/4.png)
