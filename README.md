# ProjetoZoomDigital

Redimensionamento de imagens com FPGA (Intel Altera Ciclone V // CPLD DE1-SoC em Verilog.
**Componentes:** Maria José Ramos Neta, Guilherme Moreira Gonçalves dos Santos e Adson Víctor de Souza Alves

**INTRODUÇÃO**
  Tendo em vista a evolução dos sistemas panópticos, o desafio propõe a implementação de um módulo embarcado para sistemas de vigilância e exibição em tempo real. O algoritmo possui efeitos de *zoom* e *downscale*, simulando o comportamento básico da interpolação visual. Atravéz das chaves e botões da FPGA, esse co-processador gráfico funcionará retornando imagens ampliadas ou reduzidas em uma escala de 2x.

**LEVANTAMENTO DE REQUISITOS**
- O código deve ser escrito em linguagem Verilog
- O sistema só poderá usar componetes disponíveis na placa
- Possuir, em escala de 2x os algoritmos de: Zoom in, nearest neighbor interpolation, nearest neighbor for zoom out, block avaregin, pixel replication e zoom out
- Representação ds imagens em escala de cinza
- Cada pizel deve ser expressado por um número inteiro de 8 bits
- Utilizar chaves e/ou botões para determinar a ampliação ou redução da imagem 
- Coprocessador e processador compatíveis  

**DETALHAMENTO DO SOFTWARE**
  
  - O código foi robustamente pensado e desenvolvido em cima de 2 máquinas de estados, sendo a principal o 'Coprocessor.v', que é a main do código. O módulo coprocessor é responsável pelo processamento de imagens e exibição dos resultados em uma interface VGA, com a possibilidade de seleção entre algoritmos de processamento. Ele integra diversos subsistemas que gerenciam leitura de imagem, aplicação de algoritmos, armazenamento em memória RAM, e exibição via sinal VGA. O sistema é controlado por sinais de entrada como RUN, RESET e ALGORITHM_SELECTOR, e fornece feedback visual por meio de displays de 7 segmentos. O módulo controller gerencia o estado de processamento, controlando: início do processo (START = !RUN); finalização do algoritmo (PROC_DONE); habilitação do processamento (PROC_ENABLE); seleção da fonte de dados VGA (VGA_SOURCE_SELECT). 
  - **'Zoom_controller.v'** é outro algorítmo essencial para o funcionamento do projeto,que utiliza um barramento de 2 bits, pois nele cada pulso em SELECT muda o algoritmo em um ciclo de 4 etapas. Quando 'zoom_requested' é acionado: se o algoritmo atual é de ampliação (S_NN ou S_PR), a imagem vai para 320×240; se é de redução (S_DC ou S_BA), a imagem vai para 80×60; caso contrário, fica em 160×120. Há também um Reset global: um pulso em RESET volta tudo para o algoritmo S_NN e estado de tamanho padrão.
  - **'Data_management'** é o módulo que lê pixels da ROM, aplica o algoritmo selecionado (ALGORITHM) e escreve os pixels processados no RAMProc. Internamente é um FSM que controla leitura sequencial da ROM e gera escritas no RAM (replicações, médias, etc.). Sua entradas e saídas principais são: PIXEL_IN[7..0] (vindo da ROM), PIXEL_OUT[7..0] (para escrever no RAM), wren_out (write enable RAM), W_ADDR[16..0] (endereço de escrita), R_ADDR[14..0] (endereço de leitura da ROM?), done (fim do processamento).
  - **'RAMProc (RAM)'** tem a função de armazenar a imagem processada (a ser lida pelo VGA). Vale a pena ressaltar que há um **'ROMinit'** (pois há o uso da ROM)a para inicializar os dados originais e outra conexão direta para o VGA (para mostrar imagem original se necessário).
  - **'vga_clock', 'vga_controller', 'vga_module', 'display'** são *essenciais* para amostragem das imagens resultantes, tendo sido, logicamente, os primeiros algorítmos desenvolvidos no projeto. vga_clock gera CLK_OUT_25 (25MHz) necessário para VGA padrão. vga_controller usa IMG_WIDTH_OUT/IMG_HEIGHT_OUT para calcular X_CUR_COORD/Y_CUR_COORD e gerar R_ADDR (endereço de leitura de pixel para a memória usada pelo VGA). vga_module recebe color_in[7..0] (grayscale) e gera sinais RGB/HS/VS para o conector VGA; normalmente replica color_in para R,G,B (ex.: red = green = blue = color_in) para **manter escala de cinza**.
  
  
**ESPECIFICAÇÃO DO HARDWARE USADO**
- Kit de desenvolvimento DE1-SoC
- Dispositivo Altera Cyclone® V SE 5CSEMA5F31C6N device
- 64MB SDRAM (16-bit data bus)
- Quatro fontes de clock de 50MHz do gerador de clock
- Dez switches
- 800MHz Dual-core ARM Cortex-A9 MPCore processor
- 1GB DDR3 SDRAM (32-bit data bus)

**DETALHES DE INSTALAÇÃO E CONFIGURAÇÃO**
   ---> Pré-requisitos
    - Sistema Operacional Windows 10/11 (64 bits) ou Linux 64 bits.  
    - Intel Quartus Prime Lite	21.1 ou superior (recomendado 21.1, pois foi a última com suporte pleno à DE1-SoC sem necessidade de patch)
    ---Importante: se utilizar uma versão do Quartus inferior a 20.x, alguns IPs de memória (como a RAM de 17 bits) podem exigir atualização manual.---
   ---> Instalação
    - Execute o instalador como administrador.
    - Aceite os padrões, garantindo que “Cyclone V Device Support” esteja marcado.
    - Configurar variáveis de ambiente (opcional)
    - Se pretende rodar scripts de linha de comando (quartus_sh), adicione a pasta quartus/bin ao PATH do sistema.
    
     <<A instalção do projeto é bem simples! Apenas instale o projeto e execute o arquivo QPF no Quartus Prime.>>
  
**DESCRIÇÃO DOS TESTES**

  - Os testes desse projeto foram feitos essenialmente a partir das notificações mostradas pelo painel de compilação do Quartus, a cada erro mostrado, as alterações necessárias eram feitas. Quanto aos testes lógicos e algorítmicos, estes também foram feitos amiúde atravéz de esboços manuais no quadro, com a especulação e simulação de cada passo do programa. Além do mais, por meio dos LABS e da documentação disponibilizados, foi possível reunir uma série de conhecimentos e saberes úteis para o desenvolvimento de um código limpo.  Por último, mas não menos importante, o código foi constantemente testado nas telas e placas disponibilizados em nosso laboratório e, com a ajuda dos monitores, foi possível visualizar uma série de problemas lógicos que, a primeira vista, não foram notados.
  
**ANÁLISE DE RESULTADOS**

- Os resultados obtidos com o coprocessador gráfico em Verilog demonstram que o sistema atendeu plenamente às especificações propostas. A FPGA foi capaz de executar os quatro algoritmos de redimensionamento em fator 2× – dois de ampliação e dois de redução – processando imagens em escala de cinza de 8 bits com estabilidade e sem auxílio de processadores externos. Durante os testes na DE1-SoC, a troca de algoritmos via chaves e a atualização imediata da imagem na saída VGA confirmaram o correto funcionamento do controle por hardware e do fluxo de dados entre ROM, módulo de processamento e RAM. A qualidade visual obtida em cada modo, especialmente na média de blocos, evidenciou que a lógica de cálculo e o uso de acumuladores de 10 bits evitaram perdas de precisão. Além disso, a latência baixa e o sincronismo com o clock de 25 MHz da interface VGA comprovam a eficiência da arquitetura e a viabilidade do projeto como base para etapas mais avançadas, como a integração com o processador ARM para manipulação de imagens em tempo real.
____________________________________________________________________________________________________________________


**#DigitalZoomProject**

Image resizing with FPGA (Intel Altera Ciclone V // CPLD DE1-SoC in Verilog.
**Components:** Maria José Ramos Neta, Guilherme Moreira Gonçalves dos Santos, and Adson Víctor de Souza Alves

**INTRODUCTION**
  Given the evolution of panoptic systems, the challenge proposes the implementation of an embedded module for real-time vision and display systems. The algorithm features zoom and downscale effects, simulating the basic behavior of visual interpolation. Using the FPGA's switches and buttons, this graphics coprocessor will return enlarged or reduced images at a 2x scale.

**REQUIREMENTS ASSESSMENT**
- The code must be written in Verilog language
- The system may only use components available on the board
- Equipped with the following algorithms at a 2x scale: Zoom in, nearest neighbor interpolation, and closest neighbor Next to zoom out, lock avarigin, pixel replication, and zoom out
- Grayscale image representation
- Each pixel must be expressed as an 8-bit integer
- Use of switches and/or buttons to determine image enlargement or reduction
- Compatible coprocessor and processor

**SOFTWARE DETAILING**
  The code was robustly designed and developed on top of 2 state machines, with the main one being 'Coprocessor.v', which is the main part of the code. The coprocessor module is responsible for image processing and displaying the results on a VGA interface, with the ability to select between processing algorithms. It integrates several subsystems that manage image reading, algorithm application, storage in RAM, and display via VGA signal. The system is controlled by input signals such as RUN, RESET, and ALGORITHM_SELECTOR, and provides visual feedback through 7-segment displays. The controller module manages the processing state, controlling: start of the process (START = !RUN); completion of the algorithm (PROC_DONE); enabling of processing (PROC_ENABLE); selection of the VGA data source (VGA_SOURCE_SELECT).
  **'Zoom_controller.v'** is another essential algorithm for the operation of the project, which uses a 2-bit bus, as each pulse in SELECT changes the algorithm in a cycle of 4 stages. When 'zoom_requested' is triggered: if the current algorithm is for zooming in (S_NN or S_PR), the image goes to 320×240; if it is for zooming out (S_DC or S_BA), the image goes to 80×60; otherwise, it stays at 160×120. There is also a global Reset: a pulse on RESET returns everything to the S_NN algorithm and the default size state.
  **'Data_management'** is the module that reads pixels from the ROM, applies the selected algorithm (ALGORITHM), and writes the processed pixels to RAMProc. Internally, it functions as a FSM that controls sequential reading from the ROM and generates writes to the RAM (replications, averages, etc.). Its main inputs and outputs are: PIXEL_IN[7..0] (coming from the ROM), PIXEL_OUT[7..0] (to write to the RAM), wren_out (write enable for RAM), W_ADDR[16..0] (write address), R_ADDR[14..0] (ROM read address?), done (end of processing). **'RAMProc (RAM)'** serves the purpose of storing the processed image (to be read by the VGA). It is worth highlighting that there is a **'ROMinit'** (due to the use of the ROM) to initialize the original data and another direct connection to the VGA (to display the original image if necessary).
  **'vga_clock', 'vga_controller', 'vga_module', 'display'** are *essential* for sampling the resulting images, having logically been the first algorithms developed in the project. vga_clock generates CLK_OUT_25 (25MHz) necessary for standard VGA. vga_controller uses IMG_WIDTH_OUT/IMG_HEIGHT_OUT to calculate X_CUR_COORD/Y_CUR_COORD and generate R_ADDR (reading address of pixel for the memory used by the VGA). vga_module receives color_in[7..0] (grayscale) and generates RGB/HS/VS signals for the VGA connector; it usually replicates color_in to R,G,B (e.g.: red = green = blue = color_in) to **maintain grayscale**.

  **HARDWARE SPECIFICATION USED**
  DE1-SoC Development Kit
  Altera Cyclone® V SE 5CSEMA5F31C6N 
  device64MB SDRAM (16-bit data bus)
  Four 50MHz clock sources from the clock generator
  Ten switches
  800MHz Dual-core ARM Cortex-A9 MPCore processor
  1GB DDR3 SDRAM (32-bit data bus)

  **INSTALLATION AND SETUP DETAILS**
---> Prerequisites
Operating System: Windows 10/11 (64-bit) or Linux 64-bit.
Intel Quartus Prime Lite 21.1 or higher (21.1 recommended, as it was the last with full DE1-SoC support without the need for patching)
---Important: If you use a Quartus version lower than 20.x, some memory IPs (such as 17-bit RAM) may require manual refreshing.---
---> Installation
Run the installer as an administrator.
Accept the defaults by ensuring that "Cyclone V Device Support" is checked.
Configure environment variables (optional)
If you want to run command-line (quartus_sh) scripts, add the quartus/bin folder to the system PATH.

**TEST DESCRIPTION** 
The tests for this project were primarily based on the notifications shown by the Quartus compilation panel; for each error presented, necessary changes were made. As for the logical and algorithmic tests, these were also frequently performed through manual sketches on the board, involving speculation and simulation of each step of the program. Furthermore, through the LABS and documentation provided, it was possible to gather a series of useful knowledge and skills for the development of clean code. Last but not least, the code was constantly tested on the screens and boards available in our laboratory, and with the help of the monitors, it was possible to visualize a series of logical problems that were not noticed at first glance. 

**RESULTS ANALYSIS**
The results obtained with the graphics coprocessor in Verilog demonstrate that the system fully met the proposed specifications. The FPGA was able to execute the four scaling algorithms at a factor of 2× – two for enlargement and two for reduction – processing 8-bit grayscale images with stability and without the assistance of external processors. During the tests on the DE1-SoC, the switching of algorithms via switches and the immediate update of the image on the VGA output confirmed the correct operation of hardware control and the flow of data between ROM, processing module, and RAM. The visual quality achieved in each mode, especially in block averaging, demonstrated that the calculation logic and the use of 10-bit accumulators prevented losses in precision. Furthermore, the low latency and synchronization with the 25 MHz clock of the VGA interface prove the efficiency of the architecture and the feasibility of the project as a basis for more advanced stages, such as integration with the ARM processor for real-time image manipulation.
