// 터미널이 열릴 때 가장 먼저 찍는 작은 로고 (ASCII 아트, 글자마다 색을 다르게)
const LETTERS: Array<{ color: number; rows: string[] }> = [
    { color: 81,  rows: [' _____ ', '| ____|', '|  _|  ', '| |___ ', '|_____|'] },                       // E
    { color: 111, rows: [' _   ', '| |_ ', '| __|', '| |_ ', ' \\__|'] },                                  // t
    { color: 141, rows: ['        ', ' _   _  ', '| | | | ', '| |_| | ', ' \\__,_| '] },                  // u
    { color: 213, rows: ['     _  ', '  __| | ', ' / _` | ', '| (_| | ', ' \\__,_| '] },                  // d
    { color: 220, rows: ['       ', '  ___  ', ' / _ \\ ', '|  __/ ', ' \\___| '] },                       // e
]

const RESET = '\x1b[0m'
const logo = [0, 1, 2, 3, 4].map((r) => LETTERS.map((l) => `\x1b[38;5;${l.color}m${l.rows[r]}`).join('') + RESET).join('\r\n')

export const ETUDE_BANNER = `\r\n${logo}\r\n\x1b[2m  ETUDE · 직접 해 보며 배우는 현장 실습${RESET}\r\n\r\n`
