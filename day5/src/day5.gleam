import gleam/int
import gleam/list
import gleam/string
import simplifile
import gleam/io

type Range {
  Range(left: Int, right: Int)
}

fn read_data() -> #(List(Range), List(Int)) {
  let assert Ok(content) = simplifile.read("data.txt")
  let content = string.trim(content)
  let splits = string.split(content, "\n\n")
  let assert Ok(ranges) = list.first(splits)
  let assert Ok(ids) = list.last(splits)

  let ranges = ranges
    |> string.trim()
    |> string.split("\n")
    |> list.map(string.trim)
    |> list.map(fn (s) {
      let splits = string.split(s, "-")
      let assert Ok(left_s) = list.first(splits)
      let assert Ok(right_s) = list.last(splits)
      let assert Ok(left) = int.parse(left_s)
      let assert Ok(right) = int.parse(right_s)
      Range(left, right)
    })

  let ids = ids
    |> string.trim()
    |> string.split("\n")
    |> list.map(string.trim)
    |> list.map(fn (s) {
      let assert Ok(id) = int.parse(s)
      id
    })
  #(ranges, ids)
}

fn task1(data: #(List(Range), List(Int))) -> Int {
  let #(ranges, ids) = data
  list.count(ids, fn(id) {
    list.any(ranges, fn (rng) {
      id >= rng.left && id <= rng.right 
    })
  })
}

fn task2(data) -> Int {
  let #(rngs, _) = data
  let #(result, _) = task2_helper([], rngs)
  list.fold(result, 0, fn(s, rng) {
    s + rng.right - rng.left + 1
  })
}

fn task2_helper(results, rngs) -> #(List(Range), List(Range)) {
  case rngs {
    [] -> #(results, rngs)
    [first, ..rest] -> {
      let #(results, fold_res) = fold_to_results(results, first)
      case fold_res {
        Ok(new_rng) -> task2_helper(results, [new_rng, ..rest])
        Error(_) -> {
          task2_helper([first, ..results], rest)
        }
      }
    }
  }
}

fn fold_to_results(results, rng) -> #(List(Range), Result(Range, Nil)){
  case results {
    [] -> #([], Error(Nil))
    [one, ..rest] -> {
      case fold_ranges(one, rng) {
        Ok(r) -> #(rest, Ok(r))
        Error(_) -> {
          let #(new_rest, res) = fold_to_results(rest, rng)
          #([one, ..new_rest], res)
        }
      }
    }
  }
}

fn fold_ranges(rng1: Range, rng2: Range) -> Result(Range, Nil) {
  case does_intersect(rng1, rng2) {
    True -> Ok(Range(int.min(rng1.left, rng2.left), int.max(rng1.right, rng2.right)))
    False -> Error(Nil)
  }
}

fn does_intersect(rng1: Range, rng2: Range) -> Bool {
  let intersects_right = rng1.left >= rng2.left && rng1.left <= rng2.right
  let intersects_left = rng1.right >= rng2.left && rng1.right <= rng2.right
  let inside = {rng1.right <= rng2.right && rng1.left >= rng2.left} ||
    {rng2.right <= rng1.right && rng2.left >= rng1.left}
  intersects_right || intersects_left || inside
}

pub fn main() -> Nil {
  read_data() |> task1() |> int.to_string() |> io.println()
  read_data() |> task2() |> int.to_string() |> io.println()
}
