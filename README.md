# Lua-scripts

## Rodar em simulação



Para testar os scripts de Lua em simulação utilizando a QGround e o SITL do ardupilot, basta seguir os seguintes passos:

-  Rodar a qground 

        ./QGroundControl.AppImage

-  Rodar o SITL 
        
        ardupilot/ArduCopter/sim_vehicle.py
            
-   Habilitar os scripts na QGS :

    - Clicar no ícone com o Q no canto superior esquerdo;
    - Ir em Vehicle Setup;
    - Ir em parameters;
    - Buscar por "SCR_ENABLE" e selecioná-lo;
    - Mudar o valor de None para Lua (ou de 0 para 1);
    - Salvar (Talvez seja necessário encerrar e rodar novamente a simulação);



-  Será criada uma pasta "scripts" na pasta em que a simulação estiver rodando (ardupilot/ArduCopter)

-  Adicione os script de lua nessa pasta e, ao rodar novamente o STIL, todos os scripts da pasta serão executados;

## Rodar no drone real

Para rodar os scripts no drone real, devemos enviar os arquivos de lua para o cartão SD do drone. Abaixo está o passo a passo:


-  Retirar o cartão SD do drone;
-   Abrir o conteúdo do cartão SD no computador (Talvez seja necessário o uso de um adaptador para leitura de micro SD);
-  O SD deve conter uma pasta APM e, dentro dela, uma pasta scripts. Se não houver, crie as duas;
-  Adicione ou modifique scripts de lua na pasta APM/scripts;
-  Devolva o SD para o drone (Certifique-se de que encaixou certo, pois é bem fácil colocar errado);

Agora, para configurar os scripts pela QGround:

-  Rodar a qground 
        ./QGroundControl.AppImage
-  Conecte o Drone ao seu computador (com USB diretamente ou por telemetria);
-  Habilitar os scripts na QGS :

    - Clicar no ícone com o Q no canto superior esquerdo;
    - Ir em Vehicle Setup;
    - Ir em parameters;
    - Buscar por "SCR_ENABLE" e selecioná-lo;
    - Mudar o valor de None para Lua (ou de 0 para 1);
    - Salvar (Talvez seja necessário conectar e desconectar o drone);

-   Caso esteja ocorrendo um erro de scripts out of memory:
    - Clicar no ícone com o Q no canto superior esquerdo;
    - Ir em Vehicle Setup;
    - Ir em parameters;
    - Buscar por "SCR_DIR_DISABLE e marcar a caixinha com ROMFS (significa que ele não irá buscar scripts na pasta ROMFS, e sim na pasta APM/scripts);
    - Salvar (Talvez seja necessário conectar e desconectar o drone);

Pronto, agora assim que você ligar o drone os scripts já serão executados.