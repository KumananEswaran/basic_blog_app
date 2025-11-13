module.exports = {
	content: [
		"./app/views/**/*.html.erb",
		"./app/helpers/**/*.rb",
		"./app/javascript/**/*.js",
		"./app/assets/**/*.css",
	],
	safelist: [
		// explicit classes you used as utilities
		"w-72",
		"w-80",
		"w-64",
		"sm:w-1/2",
		"md:w-1/3",
		"lg:w-1/4",
	],
	theme: {
		extend: {
			spacing: {
				72: "18rem",
				80: "20rem",
			},
		},
	},
	plugins: [],
};
