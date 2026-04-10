# Navegacao Rapida no Neovim - Single Buffer Workflow

## Filosofia

Um buffer, uma tela, zero distracao.
Nao precisa de sidebar, nao precisa de split.
Voce teleporta entre arquivos.

---

## Achar Arquivos

| Keybind       | O que faz                          |
|---------------|------------------------------------|
| `<leader>sf`  | Busca arquivo por nome (telescope) |
| `<leader>sg`  | Grep no projeto inteiro            |
| `<leader>sw`  | Grep a palavra sob o cursor        |
| `<leader>s.`  | Arquivos recentes (oldfiles)       |
| `<leader>sb`  | Buffers abertos                    |
| `<leader>sn`  | Arquivos da config do nvim         |
| `<leader>sp`  | Trocar de projeto                  |
| `<leader>sr`  | Reabrir ultima busca do telescope  |

**Dica:** `<leader>sf` eh o que voce mais vai usar. Nao precisa saber o caminho,
so o nome do arquivo ou parte dele.

---

## Harpoon - Seus 4 Arquivos Principais

Harpoon eh pra arquivos que voce ta mexendo AGORA.
Pensa nele como 4 slots de teleporte.

| Keybind       | O que faz                        |
|---------------|----------------------------------|
| `<leader>ma`  | Adiciona arquivo atual na lista  |
| `<leader>mm`  | Abre o menu (reordena, remove)   |
| `<leader>1`   | Vai pro arquivo do slot 1        |
| `<leader>2`   | Vai pro arquivo do slot 2        |
| `<leader>3`   | Vai pro arquivo do slot 3        |
| `<leader>4`   | Vai pro arquivo do slot 4        |

**Fluxo tipico:**
1. Abre os arquivos que vai mexer
2. `<leader>ma` em cada um
3. `<leader>mm` pra reordenar se precisar
4. `<leader>1-4` pra pular entre eles instantaneamente

---

## Jumplist - Ctrl+O / Ctrl+I

O jumplist eh automatico. Toda vez que voce pula pra outro lugar
(gd, /, <leader>sf, etc), o vim lembra de onde voce veio.

| Keybind  | O que faz                            |
|----------|--------------------------------------|
| `<C-o>`  | Volta pro lugar anterior (back)      |
| `<C-i>`  | Avanca pro lugar seguinte (forward)  |
| `:jumps` | Lista todo o historico de jumps       |

**Isso eh tipo o botao de voltar do browser.**
Abriu um arquivo pelo telescope? `<C-o>` te traz de volta.
Foi pra definicao com `gd`? `<C-o>` volta.

---

## Alternate File

| Keybind      | O que faz                                |
|--------------|------------------------------------------|
| `<leader>a`  | Alterna entre o arquivo atual e o ultimo |

Perfeito pra quando voce ta pulando entre 2 arquivos so.
Mais rapido que harpoon pra esse caso.

---

## Oil - Navegacao por Diretorio

Oil abre o diretorio NO BUFFER, nao numa sidebar.
Voce navega como se fosse um arquivo normal.

| Keybind      | O que faz                              |
|--------------|----------------------------------------|
| `-`          | Abre o diretorio pai do arquivo atual  |
| `<leader>e`  | Mesmo que `-`                          |
| `<CR>`       | Entra no diretorio / abre arquivo      |
| `-` (dentro) | Sobe um nivel                          |
| `g.`         | Mostra/esconde arquivos ocultos        |
| `q`          | Fecha o oil                            |

**Dica:** Voce pode RENOMEAR, DELETAR e MOVER arquivos direto no oil.
Edita o nome do arquivo como texto, salva com `:w`, e ele aplica.

---

## Terminal

| Keybind  | O que faz                             |
|----------|---------------------------------------|
| `<C-\>`  | Toggle terminal flutuante             |
| `<C-\>`  | (dentro do terminal) fecha ele        |
| `<Esc><Esc>` | Sai do modo terminal pro normal  |

O terminal flutua por cima do seu buffer. Abre, faz o que precisa, fecha.
Seu codigo continua intocado embaixo.

---

## LSP - Pular pra Codigo

| Keybind  | O que faz                       |
|----------|---------------------------------|
| `gd`     | Vai pra definicao               |
| `gr`     | Lista referencias               |
| `gI`     | Vai pra implementacao           |
| `K`      | Hover documentation             |
| `<C-o>`  | Volta depois de qualquer jump   |

---

## Resumo Mental

```
Preciso achar um arquivo       ->  <leader>sf
Preciso achar um texto         ->  <leader>sg
Preciso ver os arquivos aqui   ->  -
Preciso voltar pra onde eu tava ->  <C-o>
Preciso ir pro arquivo X rapido ->  <leader>1-4 (harpoon)
Preciso alternar 2 arquivos    ->  <leader>a
Preciso rodar um comando       ->  <C-\>
```

---

## Regra de Ouro

Se voce ta pensando em abrir um split, para e pensa:
- Preciso VER dois arquivos ao mesmo tempo? (raro, e ta ok abrir split)
- Ou preciso NAVEGAR entre dois arquivos? (harpoon / alternate / jumplist)

99% das vezes eh o segundo caso.
