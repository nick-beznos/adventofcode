use std::fs;


fn main() {
    let mut max_calories_sum = 0; 
    let mut current_elf_sum = 0;
    let mut elfs_sums: Vec<i32> = vec![];

    let input = fs::read_to_string("Input.txt").expect("Unable to read file");
    
    
    for line in input.lines() { 
        match line.trim().parse::<i32>() {
            Ok(n) => {
                current_elf_sum += n;
            },
            Err(_e) => {
                elfs_sums.insert(elfs_sums.len(), current_elf_sum);

                if current_elf_sum > max_calories_sum {
                    max_calories_sum = current_elf_sum
                }
                current_elf_sum = 0
            },
          }
    }

    println!("{}", max_calories_sum);

    elfs_sums.sort_by(|a, b| a.cmp(b));

    let top_three_sum: i32 = elfs_sums.iter().rev().take(3).sum();

    println!("{}", top_three_sum);
}