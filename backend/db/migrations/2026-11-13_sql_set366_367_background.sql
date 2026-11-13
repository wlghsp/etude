-- 세트 366·367 1번 문제: 테이블 구조와 배경 설명을 앞에 덧붙인다. 여러 번 실행해도 안전하다 (이미 붙었으면 건너뜀). 채점은 바꾸지 않는다.
UPDATE quest SET description = CONCAT('**배경** — `SELECT` 는 표(테이블)에서 원하는 행과 컬럼만 꺼내 보는 문장입니다. 이 세트의 문제는 작은 가게 데이터베이스 `shop`(`mariadb shop -e ''쿼리''` 로 접속해 실행)을 씁니다. 문제마다 처음 상태에서 다시 시작합니다.

- `customers`(고객 6명): `id`, `name`, `city`(Seoul·Busan·Daegu)
- `products`(상품 5개): `id`, `name`, `price`, `category`(stationery·electronics)
- `orders`(주문 10건): `id`, `customer_id`, `product_id`, `qty`

컬럼 구성이 헷갈리면 `DESCRIBE 테이블;` 로 볼 수 있습니다.

**문제** — ', description) WHERE quest_set_id = 366 AND order_index = 1 AND description NOT LIKE '**배경**%';
UPDATE quest SET description = CONCAT('**배경** — `INSERT`·`UPDATE`·`DELETE` 는 표의 데이터를 **바꾸는** 문장입니다. 이 세트의 문제는 작은 가게 데이터베이스 `shop`(`mariadb shop -e ''쿼리''` 로 접속해 실행)을 씁니다. 문제마다 처음 상태에서 다시 시작하니 마음껏 시도해도 됩니다.

- `customers`(고객 6명): `id`, `name`, `city`(Seoul·Busan·Daegu) / `customers_backup`: 같은 구조의 빈 테이블
- `products`(상품 5개): `id`, `name`, `price`, `category`(stationery·electronics)
- `orders`(주문 10건): `id`, `customer_id`, `product_id`, `qty`
- `accounts`(계좌 2개): `id`, `owner`, `balance` (kim 10000, lee 5000)

컬럼 구성이 헷갈리면 `DESCRIBE 테이블;` 로 볼 수 있습니다.

**문제** — ', description) WHERE quest_set_id = 367 AND order_index = 1 AND description NOT LIKE '**배경**%';
