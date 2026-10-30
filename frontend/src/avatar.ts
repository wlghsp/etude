// 사용자 아바타 색: 이름으로 정해져서 사람마다 다르고, 어느 화면에서나 같다.
// Tailwind 는 클래스를 문자열 그대로 찾아서 만들므로 모두 완성된 문자열로 적는다.
const AVATAR_TONES = [
    'bg-gradient-to-br from-rose to-accent',
    'bg-gradient-to-br from-sky to-info',
    'bg-gradient-to-br from-success to-teal',
    'bg-gradient-to-br from-warning to-coral',
    'bg-gradient-to-br from-accent to-info',
    'bg-gradient-to-br from-gold to-warning',
    'bg-gradient-to-br from-lime to-success',
    'bg-gradient-to-br from-coral to-rose',
]

export function avatarTone(name: string): string {
    let h = 0
    for (const ch of name) h = (h * 31 + ch.codePointAt(0)!) >>> 0
    return AVATAR_TONES[h % AVATAR_TONES.length]!
}
