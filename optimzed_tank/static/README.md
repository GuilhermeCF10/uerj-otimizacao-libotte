# Diretório `static`

Este diretório contém os arquivos estáticos da aplicação, que são servidos diretamente ao navegador do cliente.

## Estrutura

-   **`/js`**: Contém os arquivos JavaScript da aplicação.
    -   `main.js`: O principal arquivo JavaScript do frontend. Ele é responsável por:
        -   Gerenciar a interface do usuário (UI), como a troca de abas e o estado de carregamento.
        -   Coletar os dados de entrada do formulário.
        -   Realizar chamadas `fetch` para o backend (`/optimize` e `/compare`).
        -   Receber os resultados e renderizar os gráficos usando a biblioteca Plotly.js.
        -   Implementar a animação das trajetórias de otimização nos gráficos.
        -   Popular as tabelas de resultados.
