-- =====================================================================
-- V1__init_schema.sql
-- Cinema ticket booking: RBAC + cinema + booking
-- Conventions:
--   * id          : BIGINT identity primary key (PRIMARY KEY already implies NOT NULL)
--   * created_at / updated_at : mirror BaseEntity
--   * deleted_at : only on tables that use soft delete
--   * No extra indexes yet (only UNIQUE on single columns)
-- =====================================================================

-- ===================== RBAC =====================

CREATE TABLE users (
    id            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name     VARCHAR(100) NOT NULL,
    email         VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    phone         VARCHAR(20),
    is_active     BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ,
    deleted_at    TIMESTAMPTZ
);
-- a user has many roles (via user_roles)
-- a user has many bookings

CREATE TABLE roles (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name        VARCHAR(50) NOT NULL UNIQUE,   -- ADMIN, STAFF, CUSTOMER
    description VARCHAR(255),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ,
    deleted_at  TIMESTAMPTZ
);
-- a role has many users (via user_roles)
-- a role has many permissions (via role_permissions)

CREATE TABLE permissions (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name        VARCHAR(100) NOT NULL UNIQUE,  -- MOVIE_CREATE, BOOKING_READ_ALL ...
    description VARCHAR(255),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ
);
-- a permission belongs to many roles (via role_permissions)

CREATE TABLE role_permissions (
    id            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    role_id       BIGINT NOT NULL REFERENCES roles(id),
    permission_id BIGINT NOT NULL REFERENCES permissions(id)
);

CREATE TABLE user_roles (
    id      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id),
    role_id BIGINT NOT NULL REFERENCES roles(id)
);

-- ===================== Cinema =====================

CREATE TABLE movies (
    id               BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title            VARCHAR(200) NOT NULL,
    duration_minutes INT          NOT NULL,
    release_date     DATE,
    created_at       TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at       TIMESTAMPTZ,
    deleted_at       TIMESTAMPTZ
);
-- a movie has many showtimes

CREATE TABLE theaters (
    id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name       VARCHAR(100) NOT NULL,
    address    VARCHAR(255),
    created_at TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);
-- a theater has many rooms

CREATE TABLE rooms (
    id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    theater_id BIGINT      NOT NULL REFERENCES theaters(id),
    name       VARCHAR(50) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);
-- a room belongs to one theater, has many seats, has many showtimes

CREATE TABLE seats (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    room_id     BIGINT      NOT NULL REFERENCES rooms(id),
    row_label   VARCHAR(2)  NOT NULL,
    seat_number INT         NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ,
    deleted_at  TIMESTAMPTZ
);
-- a seat belongs to one specific room

CREATE TABLE showtimes (
    id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    movie_id   BIGINT        NOT NULL REFERENCES movies(id),
    room_id    BIGINT        NOT NULL REFERENCES rooms(id),
    start_time TIMESTAMPTZ   NOT NULL,
    price      NUMERIC(10,2) NOT NULL,
    created_at TIMESTAMPTZ   NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);
-- a showtime = one movie, in one room, at one time
-- a showtime has many bookings

-- ===================== Booking =====================

CREATE TABLE bookings (
    id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id      BIGINT        NOT NULL REFERENCES users(id),
    showtime_id  BIGINT        NOT NULL REFERENCES showtimes(id),
    status       VARCHAR(20)   NOT NULL DEFAULT 'PENDING',  -- PENDING, CONFIRMED, CANCELLED
    total_amount NUMERIC(10,2),
    created_at   TIMESTAMPTZ   NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ
);
-- a booking belongs to ONE user (the person who pays)
-- a booking belongs to ONE showtime
-- a booking has MANY booking_seats (one per ticket)

CREATE TABLE booking_seats (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    booking_id  BIGINT      NOT NULL REFERENCES bookings(id),
    showtime_id BIGINT      NOT NULL REFERENCES showtimes(id),
    seat_id     BIGINT      NOT NULL REFERENCES seats(id),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ
);