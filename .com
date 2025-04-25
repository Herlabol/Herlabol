<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Tic Tac Toe vs AI</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    body {
      font-family: sans-serif;
      text-align: center;
      background-color: #121212;
      color: white;
      padding: 30px;
    }

    h1 {
      font-size: 2em;
    }

    .leaderboard {
      background-color: #1f1f1f;
      padding: 10px;
      border-radius: 8px;
      display: inline-block;
      margin-bottom: 20px;
    }

    .leaderboard span {
      margin: 0 15px;
      font-weight: bold;
      color: #00ffcc;
    }

    .board {
      display: grid;
      grid-template-columns: repeat(3, 100px);
      grid-gap: 10px;
      justify-content: center;
      margin-top: 20px;
    }

    .cell {
      width: 100px;
      height: 100px;
      font-size: 2.5em;
      background-color: #2e2e2e;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      border-radius: 8px;
      user-select: none;
    }

    .cell:hover {
      background-color: #3e3e3e;
    }

    #status {
      margin-top: 20px;
      font-size: 1.2em;
    }

    button {
      margin-top: 20px;
      padding: 10px 20px;
      font-size: 1em;
      cursor: pointer;
    }
  </style>
</head>
<body>

<h1>Tic Tac Toe vs AI 🤖</h1>

<div class="leaderboard">
  <span>Player Wins: <span id="playerScore">0</span></span>
  <span>AI Wins: <span id="aiScore">0</span></span>
  <span>Draws: <span id="draws">0</span></span>
</div>

<div class="board" id="board"></div>
<div id="status"></div>
<button onclick="resetGame()">🔄 Restart</button>

<script>
  const boardElem = document.getElementById('board');
  const statusElem = document.getElementById('status');
  const playerScoreElem = document.getElementById('playerScore');
  const aiScoreElem = document.getElementById('aiScore');
  const drawsElem = document.getElementById('draws');

  let board = Array(9).fill('');
  let gameOver = false;
  let playerScore = 0, aiScore = 0, draws = 0;

  const WIN_COMBOS = [
    [0,1,2], [3,4,5], [6,7,8],
    [0,3,6], [1,4,7], [2,5,8],
    [0,4,8], [2,4,6]
  ];

  function drawBoard() {
    boardElem.innerHTML = '';
    board.forEach((cell, i) => {
      const cellDiv = document.createElement('div');
      cellDiv.classList.add('cell');
      cellDiv.textContent = cell;
      cellDiv.addEventListener('click', () => playerMove(i));
      boardElem.appendChild(cellDiv);
    });
  }

  function playerMove(i) {
    if (board[i] || gameOver) return;
    board[i] = 'X';
    drawBoard();
    if (checkWin('X')) return endGame('You win! 🎉', 'player');
    if (isDraw()) return endGame('It\'s a draw!', 'draw');

    setTimeout(botMove, 500);
  }

  function botMove() {
    const move = getBestMove();
    board[move] = 'O';
    drawBoard();
    if (checkWin('O')) return endGame('AI wins! 🤖', 'ai');
    if (isDraw()) return endGame('It\'s a draw!', 'draw');
  }

  function getBestMove() {
    let bestScore = -Infinity;
    let move;
    board.forEach((cell, i) => {
      if (!cell) {
        board[i] = 'O';
        let score = minimax(board, 0, false);
        board[i] = '';
        if (score > bestScore) {
          bestScore = score;
          move = i;
        }
      }
    });
    return move;
  }

  function minimax(newBoard, depth, isMaximizing) {
    if (checkWinStatic(newBoard, 'O')) return 10 - depth;
    if (checkWinStatic(newBoard, 'X')) return depth - 10;
    if (newBoard.every(cell => cell)) return 0;

    if (isMaximizing) {
      let best = -Infinity;
      newBoard.forEach((cell, i) => {
        if (!cell) {
          newBoard[i] = 'O';
          best = Math.max(best, minimax(newBoard, depth + 1, false));
          newBoard[i] = '';
        }
      });
      return best;
    } else {
      let best = Infinity;
      newBoard.forEach((cell, i) => {
        if (!cell) {
          newBoard[i] = 'X';
          best = Math.min(best, minimax(newBoard, depth + 1, true));
          newBoard[i] = '';
        }
      });
      return best;
    }
  }

  function checkWin(player) {
    return WIN_COMBOS.some(combo =>
      combo.every(i => board[i] === player)
    );
  }

  function checkWinStatic(b, player) {
    return WIN_COMBOS.some(combo =>
      combo.every(i => b[i] === player)
    );
  }

  function isDraw() {
    return board.every(cell => cell);
  }

  function endGame(msg, winner) {
    gameOver = true;
    statusElem.textContent = msg;

    if (winner === 'player') {
      playerScore++;
      playerScoreElem.textContent = playerScore;
    } else if (winner === 'ai') {
      aiScore++;
      aiScoreElem.textContent = aiScore;
    } else if (winner === 'draw') {
      draws++;
      drawsElem.textContent = draws;
    }
  }

  function resetGame() {
    board = Array(9).fill('');
    gameOver = false;
    statusElem.textContent = '';
    drawBoard();
  }

  drawBoard();
</script>

</body>
</html>
