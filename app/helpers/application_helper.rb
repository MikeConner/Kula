module ApplicationHelper
  EMAIL_REGEX = /\A\w.*?@\w.*?\.\w+\z/
  INVALID_EMAILS = ["joe", "joe@", "gmail.com", "@gmail.com", "@Actually_Twitter", "joe.mama@gmail", "fish@.com", "fish@biz.", "test@com"]
  VALID_EMAILS = ["j@z.com", "jeff.bennett@pittsburghmoves.com", "fish_42@verizon.net", "a.b.c.d@e.f.g.h.biz"]
  DATE_FORMAT = '%b %d, %Y'
  CSV_DATE_FORMAT = '%Y-%m-%d'
end
