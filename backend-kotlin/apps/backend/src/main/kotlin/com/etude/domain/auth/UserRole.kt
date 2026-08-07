package com.etude.domain.auth

// 00_schema.sql: role ENUM('member', 'admin') — enum 상수 이름을 스키마 값과 그대로 맞춘다
// (Hibernate EnumType.STRING은 상수 이름 자체를 문자열로 저장/비교하기 때문)
enum class UserRole { member, admin }
