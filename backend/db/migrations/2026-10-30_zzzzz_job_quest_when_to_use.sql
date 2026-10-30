-- 세트 22 #1 Job 만들기: "언제 쓰는지" 설명 보강. 여러 번 실행해도 안전하다.
UPDATE quest SET description = REPLACE(description, '**Job** 은 한 번 실행하고 끝나는 작업(백업, 데이터 처리 등)을 위한 리소스입니다. 계속 떠 있는 Deployment 와 다릅니다.', '**Job** 은 한 번 실행하고 끝나는 작업을 위한 리소스입니다. 계속 떠 있어야 하는 서버는 Deployment, 끝나면 종료되는 일은 Job 을 씁니다.

**언제 쓰나요?** DB 백업, 데이터 마이그레이션, 배치 처리, 배포 전 초기화 작업처럼 "한 번 하고 끝나는 일"에 씁니다. 정해진 시간마다 반복하려면 Job 을 주기적으로 만들어 주는 CronJob 을 씁니다.') WHERE quest_set_id = 22 AND order_index = 1;
