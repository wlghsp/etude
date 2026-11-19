// 좁은 화면에서 TopNav 의 메뉴 버튼이 SideNav 서랍을 여닫게 하는 신호.
// TopNav 와 SideNav 는 화면마다 따로 그려지는 형제라, props 대신 window 이벤트로 이어 준다.
export const TOGGLE_NAV_EVENT = 'etude:toggle-nav'
