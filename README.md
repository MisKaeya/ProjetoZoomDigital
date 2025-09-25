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
  O código foi robustamente pensado e desenvolvido em cima de 2 máquinas de estados, sendo a principal o 'Coprocessor.v', que é a main do código. O módulo coprocessor é responsável pelo processamento de imagens e exibição dos resultados em uma interface VGA, com a possibilidade de seleção entre algoritmos de processamento. Ele integra diversos subsistemas que gerenciam leitura de imagem, aplicação de algoritmos, armazenamento em memória RAM, e exibição via sinal VGA. O sistema é controlado por sinais de entrada como RUN, RESET e ALGORITHM_SELECTOR, e fornece feedback visual por meio de displays de 7 segmentos. O módulo controller gerencia o estado de processamento, controlando: início do processo (START = !RUN); finalização do algoritmo (PROC_DONE); habilitação do processamento (PROC_ENABLE); seleção da fonte de dados VGA (VGA_SOURCE_SELECT). 

**ESPECIFICAÇÃO DO HARDWARE USADO**

**DETALHES DE INSTALAÇÃO E CONFIGURAÇÃO**

**DESCRIÇÃO DOS TESTES**

**ANÁLISE DE RESULTADOS**

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
