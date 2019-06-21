# log-parser.rb

1. Hash map breakdown: {"workabledemo.com/api/accounts/3"=>4378, "www.workabledemo.com/user_password_resets"=>1, "www.workabledemo.com/petitions"=>1, "www.workabledemo.com/accounts"=>1, "sampleco.workabledemo.com/backend/subscription/update_billing"=>1, "www.workabledemo.com/uas/request-password-reset?trk=uas-resetpass"=>1}
- I iterated through each line. Used a regex to find status=404. Then used a regex to grab the path. Added that path as a key in a hash and incremented that key's value by 1 for every occurence.
2. 6.64ms (just counting service, not counting connect). I took all the lines that had a service (), and from those lines I took the value that came after service= with a regex and added that to the running total. Once I iterated through all the lines I divided that running total by the amount of lines that had a service (heroku/router) then had a avg time.
3. delayed_jobs was accessed the most (8370 times). I used a regular expression to grab the text that followed FROM and created a key in a has then incremented that value by 1 for each occurence of the word.
4. Yes, if a request has an HTTP status code in the 300s it means it was a server redirect. 302 possibilities: user tried to access a link when they were not authorized/authenticated. Hence redirect to /signin page. perhaps a user completed an action, the request with a 302 or 304 is sent back to make sure the current user is looking at the most up to date version. If 302/304, nothing has changed. therefore use the cached version of what the user WAS looking at. Perhaps a user is accessing an HOC that checks for oAuth with another service, they're still valid means they can use the cache version of whatever they were looking at.
5. Yes, 5 server errors (status 500 and 503). Why?
- `desc="Request Interrupted"`
- `ActionView::MissingTemplate:Missing template backend/reports/detailed_export, backend/base/detailed_export, application/detailed_export`
- heroku/router does not do any SQL, web/app.1 and .2 do SQL, though not every request is SQL
- heroku has what are called web dynos and work dynos, app/web.2 represents a web dyno, sends a success message upon receiving then does
- I looked at the log with id `443751935414394888` and the ones directly above to get a context. According to the SQL queries the exportation of the background report was "delayed", meaning this job has been put in the queue of jobs the dyno is working on and user has tried to access it but it is not ready yet.
