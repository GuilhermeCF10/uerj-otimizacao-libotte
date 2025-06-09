# Camada de Controle (Controller)

Este diretório contém a camada de controle da aplicação. O controlador atua como uma ponte entre a interface do usuário (View) e a lógica de otimização (Model).

## Arquivos

-   `tank_controller.py`: Este arquivo é o coração da camada de controle e é responsável por:
    -   Receber os parâmetros de entrada da interface do usuário (ponto inicial, tolerância, etc.).
    -   Selecionar o método de otimização apropriado (Steepest Descent, Newton, DFP) com base na escolha do usuário.
    -   Invocar o otimizador para executar o cálculo.
    -   Processar e formatar os resultados para serem exibidos na interface, incluindo o histórico de iterações, o custo final e os dados para a plotagem do gráfico de contorno.
    -   Oferece duas funções principais: `run_optimization` para um único método e `run_comparison` para executar e comparar todos os métodos disponíveis.
