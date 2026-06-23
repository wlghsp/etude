import Docker from 'dockerode'

export interface Quest {
  id: number
  title: string
  description: string
  hint: string
  grade: (container: Docker.Container) => Promise<boolean>
}

async function execCheck(container: Docker.Container, cmd: string[]): Promise<boolean> {
  const exec = await container.exec({ Cmd: cmd })
  await exec.start({})
  // exec 완료될 때까지 폴링
  while (true) {
    const info = await exec.inspect()
    if (!info.Running) return info.ExitCode === 0
    await new Promise((r) => setTimeout(r, 100))
  }
}

export const quests: Quest[] = [
  {
    id: 1,
    title: '/tmp/hello 디렉토리 만들기',
    description: '/tmp 경로 안에 hello라는 이름의 디렉토리를 만드세요.',
    hint: 'mkdir 명령어를 사용하세요.',
    grade: (container) => execCheck(container, ['test', '-d', '/tmp/hello']),
  },
  {
    id: 2,
    title: '파일에 내용 쓰기',
    description: '/tmp/answer.txt 파일을 만들고 첫 줄에 "done"을 입력하세요.',
    hint: 'echo 명령어와 리다이렉션(>)을 사용하세요.',
    grade: (container) => execCheck(container, ['grep', '-q', 'done', '/tmp/answer.txt']),
  },
]

export async function gradeQuest(
  containerId: string,
  questId: number,
  docker: Docker
): Promise<boolean> {
  const quest = quests.find((q) => q.id === questId)
  if (!quest) return false
  return quest.grade(docker.getContainer(containerId))
}
