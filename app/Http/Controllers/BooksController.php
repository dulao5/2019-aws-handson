<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Faker\Factory as Faker;
use Illuminate\Support\Facades\Log;

use App\Book;

class BooksController extends Controller
{
    public function index()
    {
        Log::info("index");
        return response()->json(Book::all());
    }

    public function store()
    {
        Log::info("store");
        $book = new Book();
        $book->title = "tmp title"; // Faker::create()->name();
        $book->save();

        return response()->json($book);
    }
}
