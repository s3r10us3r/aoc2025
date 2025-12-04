import gleam/int
import gleam/list
import gleam/string
import gleam/dict.{type Dict}
import simplifile
import gleam/io

fn read_data() -> Dict(#(Int, Int), String) {
  let assert Ok(content) = simplifile.read("data.txt")
  let content = string.trim(content)
  content
    |> string.split("\n")
    |> list.index_fold(dict.new(), fn(map, line, y) {
    line
      |> string.to_graphemes()
      |> list.index_fold(map, fn(map, char, x) {
        dict.insert(map, #(x, y), char)
    })
  })
}

fn task1() {
  let map = read_data()
  let result = map
    |> dict.fold(0, fn(res, point, char) {
    let #(x, y) = point
    res + case char {
      "@" -> {
        let cnt = count_paper(map, x + 1, y) +
        count_paper(map, x + 1, y + 1) +
        count_paper(map, x + 1, y - 1) +
        count_paper(map, x, y + 1) +
        count_paper(map, x, y - 1) +
        count_paper(map, x - 1, y) +
        count_paper(map, x - 1, y + 1) +
        count_paper(map, x - 1, y - 1)
        case cnt < 4 {
            True -> 1
            False -> 0
          }
      } 
      _ -> 0
    }
  })
  io.println(int.to_string(result))
}

fn task2() {
  let map = read_data()
  let result = task2_helper(map)
  io.println(int.to_string(result))
}

fn task2_helper(map) {
  let result = map
    |> dict.fold([], fn(res, point, char) {
    let #(x, y) = point
    case char {
      "@" -> {
        let cnt = count_paper(map, x + 1, y) +
        count_paper(map, x + 1, y + 1) +
        count_paper(map, x + 1, y - 1) +
        count_paper(map, x, y + 1) +
        count_paper(map, x, y - 1) +
        count_paper(map, x - 1, y) +
        count_paper(map, x - 1, y + 1) +
        count_paper(map, x - 1, y - 1)
        case cnt < 4 {
            True -> [#(x,y), ..res]
            False -> res
          }
      } 
      _ -> res
    }
  })
  case list.length(result) {
    0 -> 0
    val -> {
      let new_map = list.fold(result, map, fn(map, point) {
        dict.insert(map, point, "X")
      })
      task2_helper(new_map) + val
    }
  }
}

fn count_paper(map, x, y) {
  case dict.get(map, #(x, y)) {
    Ok("@") -> 1
    _ -> 0
  }
}

pub fn main() -> Nil {
  task1()
  task2()
}
