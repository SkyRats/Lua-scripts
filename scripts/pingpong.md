# Drone Ping-Pong Code

Esse script faz o drone ir para frente e para trás a uma distância e número de vezes definidas.

## Estados
-  0:  Muda para o Guided mode
-  1:  Takeoff até a altura `takeoff_alt` 
-  2:  Espera até atingir a altura de takeoff
-  3:  Vai para frente até a distancia definida
-  4:  Volta para a posição inicial
-  5:  Muda para o Land mode

## Variáveis:
- `takeoff_alt`: Altitude de takeoff em metros
- `copter_guided_mode_num`: Número do modo de voo Guided
- `copter_launch_mode_num`:Número do modo de voo Land
- `stage`: Estado atual do código
- `count`: Número de vezes que o drone foi pra frente
- `max_count`: Número máximo de repetições
- `ping_pong_distance`: Distância que o drone irá para frente em metros
- `vel`: Velocidade do drone em metros por segundo

## Entendendo o código:

Primeiro, há um comentário explicando o que é o código e como ele funciona. Em seguida, declaram-se as variáveis locais que serão utilizadas.
 O `copter_guided_mode_num` e o `copter_launch_mode_num `são números padrões, definidos pelo ardupilot, dos modos de voo Guided e Land, respectivamente. As demais variáveis são definições que o usuário escolhe de acordo com o comportamento que espera, indicado no comentário na frente de cada uma.

```lua
-- Esse script faz o drone ir para frente e para trás
-- a uma distância e número de vezes definidos
-- Seus estados são :
--  0) Muda para o Guided mode
--  1) Takeoff até a altura takeoff_alt 
--  2) Espera até atingir a altura de takeoff
--  3) Vai para frente até a distância definida
--  4) Volta para a posição inicial
--  5) Muda para o land mode

local takeoff_alt = 3         -- Altura de takeoff
local copter_guided_mode_num = 4
local copter_launch_mode_num = 6
local stage = 0
local count = 0               -- Número de vezes que o drone foi para frente
local max_count = 2           -- Número máximo de repetições
local ping_pong_distance = 10 -- Distância até a qual o drone deve ir para frente (m)
local vel = 1                 -- Velocidade do drone (m/s)

```


Em seguida, há a função principal do código, a função `update()`, que será chamada assim que o código for iniciado (não foi indicado um tempo de espera na últma linha do código) e o seu return indica que a função será chamada novamente 100 ms após finalizar sua execução.

```lua
function update()
    -- [Code]
    return update(), 100
end

return update()
```


No if apresentado, o código está aguardando que o drone esteja armado para mudar para o próximo estado. Foi utilizada a função `is_armed()` da biblioteca `arming` para verificar se o drone está armado ou não. Também foi utilizada a função `send_text()` da biblioteca `gcs` para enviar uma mensagem ("Arming") de severidade 6 (informação) para a QGC. Assim, enquanto o drone não estiver armado, ele permanece no estado 0 do código.

``` lua
if not arming:is_armed() then
    stage = 0
    gcs:send_text(6, "Arming")
```

Se o drone estiver armado, ele passa para o else, que apresenta um comportamento para cada um dos estados. 
No `estado 0`, mudamos o modo de voo do drone para o GUIDED MODE. Assim, utilizamos a função `set_mode()` da biblioteca `vehicle`, que recebe o número do modo de voo desejado (copter_guided_mode_num, que foi definido em nossas variáveis). Quando ele verifica que o drone aderiu ao modo de voo desejado, ele passa para o próximo estado.

``` lua
else
    if stage == 0 then
        if vehicle:set_mode(copter_guided_mode_num) then 
            stage = stage + 1
        end
``` 
No estado 1, utilizamos a função `start_takeoff()` da biblioteca `vehicle` para o drone realizar o takeoff a uma altura definida pela variável `takeoff_alt`.

``` lua
elseif stage == 1 then
    gcs:send_text(6, "Taking off")
    if vehicle:start_takeoff(takeoff_alt) then
        stage = stage + 1
    end
``` 

No estado 2, utilizamos a função `ahrs:get_home()` para obter a localização de takeoff do drone e a função `ahrs:get_position()` para obter a posição atual do drone. Na linha 4, ele verifica se os valores obtidos não são nulos. Em seguida, a função `home:get_distance_NED()` armazena em `vec_from_home` um vetor 3D, com início em `curr_loc` e fim em `home`. Na linha 7, o código envia para a GCS o valor contido na coordenada z de `vec_from_home`, ou seja, a altura atual do drone (multiplicada por -1, pois o vetor aponta para a home, que está a uma altura inferior à atual).

Quando a diferença entre `takeoff_alt` e `vec_from_home:z()` for menor que 1, indicando que o drone atingiu a altura de takeoff, ele passa para o próximo estado (utiliza-se `math.abs()` para pegar o módulo e foi realizada uma soma em vez de subtração porque a componente z é negativa).

``` lua
elseif stage == 2 then
    local home = ahrs:get_home()
    local curr_loc = ahrs:get_position()
    if home and curr_loc then 
        local vec_from_home = home:get_distance_NED(curr_loc)
        gcs:send_text(6, "Altitude above home: " .. tostring(math.floor(-vec_from_home:z())))
        if math.abs(takeoff_alt + vec_from_home:z()) < 1 then
            stage = stage + 1
        end
    end
``` 

No estado 3, primeiramente o drone checa se já realizou todas as voltas pedidas no `max_count`. Se sim, ele muda para o estado 5. Se não, ele executa os comandos do estado 3.

Primeiro ele cria um vetor 3d `target_vel` para armazenar a velocidade desejada. Em seguida, ele seta o valor de cada uma das componentes desse vetor criado (0 pra y e z e `vel` para x).

Em seguida, ele usa a fução `vehicle:set_target_velocity_NED(target_vel)` para definier a velocidade do drone como a de `target_vel`. Se ele encontra algum problema, ele envia uma mensagem de aviso.


``` lua
elseif (stage == 3) then -- Stage 3: Moving Forward
    -- Se excedeu o número de vezes, muda para o stage 5
    if (count >= max_count) then
        stage = stage + 2
    end

    -- calculate velocity vector
    local target_vel = Vector3f()
    target_vel:x(vel)
    target_vel:y(0)
    target_vel:z(0)

    -- send velocity request
    if not (vehicle:set_target_velocity_NED(target_vel)) then
        gcs:send_text(6, "Failed to execute velocity command")
    end

``` 

Depois, ele utiliza a mesma estratégia mostrada anteriormente de calcular o vetor distância do local de takeoff para verificar a distância x que andou. Quando a diferença entre a distância x que o drone deslocou e a `pinp_pong_distance` for menor que 1, ele incrementa o `count` e passa para o próximo estado.
``` lua

    -- checking if reached stop point
    local home = ahrs:get_home()
    local curr_loc = ahrs:get_position()
    if home and curr_loc then 
        local vec_from_home = home:get_distance_NED(curr_loc)
        gcs:send_text(6, "Distance from home: " .. tostring(math.floor(vec_from_home:x())))
        if(math.abs(ping_pong_distance - vec_from_home:x()) < 1) then
            count = count + 1
            stage = stage + 1
        end
    end
end

``` 
No estado quatro, a velocidade em x é multiplicada por -1 para o drone voar na direção contrária, retornando para a posição de takeoff. Quando a diferença entre a posição x do drone e a posição x de takeoff do drone for menor que 1, ele volta para o estado 3, para iniciar o movimento de ir para a frente novamente (ou não, caso o count tenha atingido o max_count).

``` lua
elseif (stage == 4) then -- Stage 4: Moving Back
    -- calculate velocity vector
    local target_vel = Vector3f()
    target_vel:x(-vel)
    target_vel:y(0)
    target_vel:z(0)

    -- send velocity request
    if not (vehicle:set_target_velocity_NED(target_vel)) then
        gcs:send_text(6, "Failed to execute velocity command")
    end

    -- checking if reached stop point
    local home = ahrs:get_home()
    local curr_loc = ahrs:get_position()
    if home and curr_loc then 
        local vec_from_home = home:get_distance_NED(curr_loc)
        gcs:send_text(6, "Distance from home: " .. tostring(math.floor(vec_from_home:x())))
        if(math.abs(vec_from_home:x()) < 1) then
            stage = stage - 1
        end
    end
end

``` 
No estado 5, o drone simplesmente muda para o modo de voo Land e pousa, indicando por mensagem que finalizou o código.
``` lua
elseif (stage == 5) then -- Stage 5: Change to LAND mode
    vehicle:set_mode(copter_rtl_mode_num)
    stage = stage + 1
    gcs:send_text(6, "Finished pingpong, switching to LAND")
end

``` 


