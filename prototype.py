from random import randint

# main funciton
def main():
    print("Enter the difficulty level:")
    difficulty = int(input())
    play_game(difficulty)

# play n = max_cycle_size cycles
def play_game(max_cycle_size):
    sequence = generate_sequence(max_cycle_size, 3)
    result = 0

    # plays the cycles in increasing size
    for i in range (1, max_cycle_size + 1):
        result = play_cicle(i, sequence)
        if result == 0:
            print("you lose hahahahahah, noob\n")
            break

    if result == 1:
        print("Congratulations! You win!")
        

# receives n = cycle_size user inputs and compares to the original sequence
# returns 0 in case of failure and 1 in case of sucess 
def play_cicle(cycle_size, sequence):
    player_victory = 1

    # show the first n = cycle_size terms of the sequence
    for i in range (0, cycle_size):
        print(sequence[i])
    print("Type the numbers in order")
    
    #ask to the user the numbers of the sequence
    for i in range (0, cycle_size):
        user_input = int(input())
        if user_input != sequence[i]:
            player_victory = 0
            break
    if player_victory == 1:
        print("correct!")
    else:
        print("wrong answer!")
    return player_victory

# generates a pseudo-random sequence of integers from 0 up to max
# returns an array with n = max positive integers
def generate_sequence(n, max):
    a = []
    for i in range (0, n):
        a.append(randint(0, max))
    return a

main()