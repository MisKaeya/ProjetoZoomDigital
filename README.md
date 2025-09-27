# ProjetoZoomDigital

Redimensionamento de imagens com FPGA (Intel Altera Ciclone V // CPLD DE1-SoC em Verilog.
**Componentes:** Maria José Ramos Neta, Guilherme Moreira Gonçalves dos Santos e Adson Víctor de Souza Alves

//**INTRODUÇÃO**
  Tendo em vista a evolução dos sistemas panópticos, o desafio propõe a implementação de um módulo embarcado para sistemas de vigilância e exibição em tempo real. O algoritmo possui efeitos de *zoom* e *downscale*, simulando o comportamento básico da interpolação visual. Atravéz das chaves e botões da FPGA, esse co-processador gráfico funcionará retornando imagens ampliadas ou reduzidas em uma escala de 2x.

//**LEVANTAMENTO DE REQUISITOS**
O sistema consiste em um coprocessador gráfico em Verilog capaz de redimensionar imagens em escala de cinza de 8 bits, realizando ampliação e redução em fator 2× por quatro algoritmos: vizinho mais próximo, replicação de pixel, decimação e média de blocos. Ele opera de forma totalmente autônoma na FPGA DE1-SoC, lendo a imagem original de uma ROM e gravando o resultado em uma RAM exibida via saída VGA. O controle é feito por chaves e botões, com feedback em displays de sete segmentos, e o projeto é modular para futura integração com o processador ARM da placa. Requisitos técnicos incluem Quartus Prime Lite 21.1 ou superior, clock de 50 MHz com geração interna de 25 MHz para o VGA, ROM de 15 bits (32 768 pixels) e RAM de 17 bits (131 072 pixels), garantindo processamento em tempo real, ausência de artefatos visuais e facilidade de manutenção ou expansão.

//**DETALHAMENTO DO SOFTWARE**
  
  - O código foi robustamente pensado e desenvolvido em cima de 2 máquinas de estados, sendo a principal o 'Coprocessor.v', que é a main do código. O módulo coprocessor é responsável pelo processamento de imagens e exibição dos resultados em uma interface VGA, com a possibilidade de seleção entre algoritmos de processamento. Ele integra diversos subsistemas que gerenciam leitura de imagem, aplicação de algoritmos, armazenamento em memória RAM, e exibição via sinal VGA. O sistema é controlado por sinais de entrada como RUN, RESET e ALGORITHM_SELECTOR, e fornece feedback visual por meio de displays de 7 segmentos. O módulo controller gerencia o estado de processamento, controlando: início do processo (START = !RUN); finalização do algoritmo (PROC_DONE); habilitação do processamento (PROC_ENABLE); seleção da fonte de dados VGA (VGA_SOURCE_SELECT). 
  - **'Zoom_controller.v'** é outro algorítmo essencial para o funcionamento do projeto,que utiliza um barramento de 2 bits, pois nele cada pulso em SELECT muda o algoritmo em um ciclo de 4 etapas. Quando 'zoom_requested' é acionado: se o algoritmo atual é de ampliação (S_NN ou S_PR), a imagem vai para 320×240; se é de redução (S_DC ou S_BA), a imagem vai para 80×60; caso contrário, fica em 160×120. Há também um Reset global: um pulso em RESET volta tudo para o algoritmo S_NN e estado de tamanho padrão.
  - **'Data_management'** é o módulo que lê pixels da ROM, aplica o algoritmo selecionado (ALGORITHM) e escreve os pixels processados no RAMProc. Internamente é um FSM que controla leitura sequencial da ROM e gera escritas no RAM (replicações, médias, etc.). Sua entradas e saídas principais são: PIXEL_IN[7..0] (vindo da ROM), PIXEL_OUT[7..0] (para escrever no RAM), wren_out (write enable RAM), W_ADDR[16..0] (endereço de escrita), R_ADDR[14..0] (endereço de leitura da ROM?), done (fim do processamento).
  - **'RAMProc (RAM)'** tem a função de armazenar a imagem processada (a ser lida pelo VGA). Vale a pena ressaltar que há um **'ROMinit'** (pois há o uso da ROM)a para inicializar os dados originais e outra conexão direta para o VGA (para mostrar imagem original se necessário).
  - **'vga_clock', 'vga_controller', 'vga_module', 'display'** são *essenciais* para amostragem das imagens resultantes, tendo sido, logicamente, os primeiros algorítmos desenvolvidos no projeto. vga_clock gera CLK_OUT_25 (25MHz) necessário para VGA padrão. vga_controller usa IMG_WIDTH_OUT/IMG_HEIGHT_OUT para calcular X_CUR_COORD/Y_CUR_COORD e gerar R_ADDR (endereço de leitura de pixel para a memória usada pelo VGA). vga_module recebe color_in[7..0] (grayscale) e gera sinais RGB/HS/VS para o conector VGA; normalmente replica color_in para R,G,B (ex.: red = green = blue = color_in) para **manter escala de cinza**.
  
  
//**ESPECIFICAÇÃO DO HARDWARE USADO**
- Kit de desenvolvimento DE1-SoC
- Dispositivo Altera Cyclone® V SE 5CSEMA5F31C6N device
- 64MB SDRAM (16-bit data bus)
- Quatro fontes de clock de 50MHz do gerador de clock
- Dez switches
- 800MHz Dual-core ARM Cortex-A9 MPCore processor
- 1GB DDR3 SDRAM (32-bit data bus)

//**DETALHES DE INSTALAÇÃO E CONFIGURAÇÃO**
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
  
//**DESCRIÇÃO DOS TESTES**

  - Os testes desse projeto foram feitos essenialmente a partir das notificações mostradas pelo painel de compilação do Quartus, a cada erro mostrado, as alterações necessárias eram feitas. Quanto aos testes lógicos e algorítmicos, estes também foram feitos amiúde atravéz de esboços manuais no quadro, com a especulação e simulação de cada passo do programa. Além do mais, por meio dos LABS e da documentação disponibilizados, foi possível reunir uma série de conhecimentos e saberes úteis para o desenvolvimento de um código limpo.  Por último, mas não menos importante, o código foi constantemente testado nas telas e placas disponibilizados em nosso laboratório e, com a ajuda dos monitores, foi possível visualizar uma série de problemas lógicos que, a primeira vista, não foram notados.
  
//**ANÁLISE DE RESULTADOS**

- Os resultados obtidos com o coprocessador gráfico em Verilog demonstram que o sistema atendeu plenamente às especificações propostas. A FPGA foi capaz de executar os quatro algoritmos de redimensionamento em fator 2× – dois de ampliação e dois de redução – processando imagens em escala de cinza de 8 bits com estabilidade e sem auxílio de processadores externos. Durante os testes na DE1-SoC, a troca de algoritmos via chaves e a atualização imediata da imagem na saída VGA confirmaram o correto funcionamento do controle por hardware e do fluxo de dados entre ROM, módulo de processamento e RAM. A qualidade visual obtida em cada modo, especialmente na média de blocos, evidenciou que a lógica de cálculo e o uso de acumuladores de 10 bits evitaram perdas de precisão. Além disso, a latência baixa e o sincronismo com o clock de 25 MHz da interface VGA comprovam a eficiência da arquitetura e a viabilidade do projeto como base para etapas mais avançadas, como a integração com o processador ARM para manipulação de imagens em tempo real.
____________________________________________________________________________________________________________________


**#DigitalZoomProject**

Image resizing with FPGA (Intel Altera Ciclone V // CPLD DE1-SoC in Verilog.
**Components:** Maria José Ramos Neta, Guilherme Moreira Gonçalves dos Santos, and Adson Víctor de Souza Alves

//**INTRODUCTION**
  Given the evolution of panoptic systems, the challenge proposes the implementation of an embedded module for real-time vision and display systems. The algorithm features zoom and downscale effects, simulating the basic behavior of visual interpolation. Using the FPGA's switches and buttons, this graphics coprocessor will return enlarged or reduced images at a 2x scale.

//**REQUIREMENTS ASSESSMENT**
The system consists of a graphics coprocessor in Verilog capable of resizing 8-bit grayscale images, performing 2× upscaling and downscaling using four algorithms: nearest neighbor, pixel replication, decimation, and block averaging. It operates fully autonomously on the DE1-SoC FPGA, reading the original image from a ROM and writing the result to a RAM displayed via VGA output. Control is handled through switches and buttons, with feedback on seven-segment displays, and the project is modular for future integration with the board's ARM processor. Technical requirements include Quartus Prime Lite 21.1 or higher, a 50 MHz clock with internal generation of 25 MHz for the VGA, 15-bit ROM (32,768 pixels) and 17-bit RAM (131,072 pixels), ensuring real-time processing, absence of visual artifacts, and ease of maintenance or expansion.

//**SOFTWARE DETAILING**
  The code was robustly designed and developed on top of 2 state machines, with the main one being 'Coprocessor.v', which is the main part of the code. The coprocessor module is responsible for image processing and displaying the results on a VGA interface, with the ability to select between processing algorithms. It integrates several subsystems that manage image reading, algorithm application, storage in RAM, and display via VGA signal. The system is controlled by input signals such as RUN, RESET, and ALGORITHM_SELECTOR, and provides visual feedback through 7-segment displays. The controller module manages the processing state, controlling: start of the process (START = !RUN); completion of the algorithm (PROC_DONE); enabling of processing (PROC_ENABLE); selection of the VGA data source (VGA_SOURCE_SELECT).
  //**'Zoom_controller.v'** is another essential algorithm for the operation of the project, which uses a 2-bit bus, as each pulse in SELECT changes the algorithm in a cycle of 4 stages. When 'zoom_requested' is triggered: if the current algorithm is for zooming in (S_NN or S_PR), the image goes to 320×240; if it is for zooming out (S_DC or S_BA), the image goes to 80×60; otherwise, it stays at 160×120. There is also a global Reset: a pulse on RESET returns everything to the S_NN algorithm and the default size state.
  //**'Data_management'** is the module that reads pixels from the ROM, applies the selected algorithm (ALGORITHM), and writes the processed pixels to RAMProc. Internally, it functions as a FSM that controls sequential reading from the ROM and generates writes to the RAM (replications, averages, etc.). Its main inputs and outputs are: PIXEL_IN[7..0] (coming from the ROM), PIXEL_OUT[7..0] (to write to the RAM), wren_out (write enable for RAM), W_ADDR[16..0] (write address), R_ADDR[14..0] (ROM read address?), done (end of processing). **'RAMProc (RAM)'** serves the purpose of storing the processed image (to be read by the VGA). It is worth highlighting that there is a **'ROMinit'** (due to the use of the ROM) to initialize the original data and another direct connection to the VGA (to display the original image if necessary).
  //**'vga_clock', 'vga_controller', 'vga_module', 'display'** are *essential* for sampling the resulting images, having logically been the first algorithms developed in the project. vga_clock generates CLK_OUT_25 (25MHz) necessary for standard VGA. vga_controller uses IMG_WIDTH_OUT/IMG_HEIGHT_OUT to calculate X_CUR_COORD/Y_CUR_COORD and generate R_ADDR (reading address of pixel for the memory used by the VGA). vga_module receives color_in[7..0] (grayscale) and generates RGB/HS/VS signals for the VGA connector; it usually replicates color_in to R,G,B (e.g.: red = green = blue = color_in) to **maintain grayscale**.

  //**HARDWARE SPECIFICATION USED**
  DE1-SoC Development Kit
  Altera Cyclone® V SE 5CSEMA5F31C6N 
  device64MB SDRAM (16-bit data bus)
  Four 50MHz clock sources from the clock generator
  Ten switches
  800MHz Dual-core ARM Cortex-A9 MPCore processor
  1GB DDR3 SDRAM (32-bit data bus)

  //**INSTALLATION AND SETUP DETAILS**
---> Prerequisites
Operating System: Windows 10/11 (64-bit) or Linux 64-bit.
Intel Quartus Prime Lite 21.1 or higher (21.1 recommended, as it was the last with full DE1-SoC support without the need for patching)
---Important: If you use a Quartus version lower than 20.x, some memory IPs (such as 17-bit RAM) may require manual refreshing.---
---> Installation
Run the installer as an administrator.
Accept the defaults by ensuring that "Cyclone V Device Support" is checked.
Configure environment variables (optional)
If you want to run command-line (quartus_sh) scripts, add the quartus/bin folder to the system PATH.

//**TEST DESCRIPTION** 
The tests for this project were primarily based on the notifications shown by the Quartus compilation panel; for each error presented, necessary changes were made. As for the logical and algorithmic tests, these were also frequently performed through manual sketches on the board, involving speculation and simulation of each step of the program. Furthermore, through the LABS and documentation provided, it was possible to gather a series of useful knowledge and skills for the development of clean code. Last but not least, the code was constantly tested on the screens and boards available in our laboratory, and with the help of the monitors, it was possible to visualize a series of logical problems that were not noticed at first glance. 

//**RESULTS ANALYSIS**
The results obtained with the graphics coprocessor in Verilog demonstrate that the system fully met the proposed specifications. The FPGA was able to execute the four scaling algorithms at a factor of 2× – two for enlargement and two for reduction – processing 8-bit grayscale images with stability and without the assistance of external processors. During the tests on the DE1-SoC, the switching of algorithms via switches and the immediate update of the image on the VGA output confirmed the correct operation of hardware control and the flow of data between ROM, processing module, and RAM. The visual quality achieved in each mode, especially in block averaging, demonstrated that the calculation logic and the use of 10-bit accumulators prevented losses in precision. Furthermore, the low latency and synchronization with the 25 MHz clock of the VGA interface prove the efficiency of the architecture and the feasibility of the project as a basis for more advanced stages, such as integration with the ARM processor for real-time image manipulation.
