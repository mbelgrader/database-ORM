DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS question_follows;
DROP TABLE IF EXISTS replies;
DROP TABLE IF EXISTS question_likes;


CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY (author_id) REFERENCES users(id)
);

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  questions_id INTEGER NOT NULL,
  users_id INTEGER NOT NULL,

  FOREIGN KEY (questions_id) REFERENCES questions(id),
  FOREIGN KEY (users_id) REFERENCES users(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  questions_id INTEGER NOT NULL,
  parent_reply_id INTEGER,
  users_id INTEGER NOT NULL,
  body TEXT,

  FOREIGN KEY (questions_id) REFERENCES questions(id),
  FOREIGN KEY (users_id) REFERENCES users(id),
  FOREIGN KEY (parent_reply_id) REFERENCES replies(id)
);

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  users_id INTEGER NOT NULL,
  questions_id INTEGER NOT NULL,

  FOREIGN KEY (questions_id) REFERENCES questions(id),
  FOREIGN KEY (users_id) REFERENCES users(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ('Maria', 'Is Cool'),
  ('Dallas', 'Is Cooler');

INSERT INTO
  questions(title, body, author_id)
VALUES
  ('how do i sql?', 'plz halp', (SELECT id FROM users WHERE fname = 'Dallas')),
  ('what is 2 + 2', 'math sux', (SELECT id FROM users WHERE fname = 'Maria'));

INSERT INTO
  question_follows(questions_id, users_id)
VALUES
  ((SELECT id FROM questions WHERE title = 'what is 2 + 2'), (SELECT id FROM users WHERE fname = 'Dallas'));

INSERT INTO
  replies(questions_id, users_id, body)
VALUES
  ((SELECT id FROM questions WHERE title = 'what is 2 + 2'), (SELECT id FROM users WHERE fname = 'Dallas'), 'this is a great question! I am struggling here');

INSERT INTO
  replies(questions_id, parent_reply_id, users_id, body)
VALUES
  ((SELECT id FROM questions WHERE title = 'what is 2 + 2'), (
      SELECT DISTINCT replies.id
      FROM replies
      JOIN users
      ON users.id = replies.users_id
      WHERE fname = 'Dallas' AND body = 'this is a great question! I am struggling here'), (
    SELECT id FROM users WHERE fname = 'Maria'), 'I know right?!?!');

INSERT INTO question_likes
  (users_id, questions_id)
VALUES
  (1, (SELECT id FROM questions WHERE title = 'how do i sql?'));
