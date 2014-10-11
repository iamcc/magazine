var app = require('koa')(),
	fs = require('fs')

app.use(require('koa-static')('public'))
app.use(require('koa-body')(app))
app.use(function * (next) {
	if (this.method !== 'POST') return yield next
	var file = random()
	fs.writeFile(file, JSON.stringify(this.request.body), function(err) {
		console.log(err)
	})
	this.body = file.split('/').splice(-1)[0]
})

app.listen(8000)

function random() {
	return 'public/json/' + (Math.random() + '').slice(-10) + '.json'
}