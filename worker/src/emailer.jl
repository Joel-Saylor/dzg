module Emailer
using SMTPClient
using Dates
function send_email(recipient, subject, body_text)
    from = "dzgrainalyzer@gmail.com"
    opt = SendOptions(
        isSSL=true,
        username=from,
        passwd=ENV["EMAIL_PASSWORD"],
    )
    formatted_time = Dates.format(now(), "E, d u Y H:M:S Z")
    body = IOBuffer(
        "Date: $formatted_time\r\n" *
        "From: DZG dzgrainalyzer@gmail.com\r\n" *
        "To: $recipient\r\n" *
        "Subject: $subject\r\n" *
        "\r\n" *
        "$body_text\r\n")
    url = "smtps://smtp.gmail.com:465"
    rcpt = [recipient]
    resp = send(url, rcpt, from, body, opt)
end
end