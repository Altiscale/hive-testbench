SELECT tmp.book_category, ROUND(tmp.revenue, 2) AS revenue
FROM (
  SELECT books.category AS book_category, SUM(books.price * transactions.quantity) AS revenue
--  FROM books JOIN [SHUFFLE] transactions ON (
  FROM books JOIN transactions ON (
    transactions.book_id = books.id
    AND YEAR(transactions.transaction_date) BETWEEN 2008 AND 2010
  )
  GROUP BY books.category
) tmp
ORDER BY revenue DESC LIMIT 10;
