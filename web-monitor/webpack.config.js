const webpack = require("webpack");
const SERVER_URL = process.env.SERVER_URL || "http://localhost:3030";

module.exports = {
    entry: "./app/index.js",
    resolve: {
        modules: ["node_modules"],
        extensions: ["*", ".js"]
    },
    resolveLoader: {
        modules: ["node_modules"],
        moduleExtensions: ["-loader"],
        extensions: ["*", ".js"]
    },
    watch: true,
    watchOptions: {
        aggregateTimeout: 100
    },
    devtool: "source-map",
    plugins: [
        new webpack.DefinePlugin({
            SERVER_URL: JSON.stringify(SERVER_URL)
        })
    ],
    output: {
        publicPath: "./dist/",
        filename: "./dist/stand_monitor.js"
    },
    module: {
        rules: [
            {
                test: /\.js$/,
                use: [
                    {
                        loader: "babel",
                        options: {
                            presets: ["react"],
                            plugins: []
                        }
                    }
                ]
            }
        ]
    }
};
