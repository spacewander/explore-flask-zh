#!/usr/bin/env bash

gitbook pdf ./zh --config ./zh/book.json ebook/Flask之旅.pdf
gitbook epub ./zh --config ./zh/book.json ebook/Flask之旅.epub
gitbook mobi ./zh --config ./zh/book.json ebook/Flask之旅.mobi
