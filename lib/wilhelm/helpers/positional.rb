# frozen_string_literal: false

module Wilhelm
  module Helpers
    # Positional Notation Helpers
    module PositionalNotation
      extend self

      BASE_2 = 2
      BASE_10 = 10
      BASE_2_BIT_SHIFT   = 1
      BASE_16_BIT_SHIFT  = 4
      BASE_256_BIT_SHIFT = 8

      # DIGITS TO NUMBER

      # Treat each element as digits in base-256 positional notation
      # e.g. [0x27, 0x06] => 0x2706 = 9990
      # @param Array<Fixnum> digits
      # @return Fixnum
      def parse_base_256_digits(*digits)
        reduce(BASE_256_BIT_SHIFT, *digits)
      end

      # Treat each element as digits in base-16 positional notation
      # e.g. [0x2, 0x7, 0x0, 0x6] => 0x2706 = 9990
      # @param Array<Fixnum> digits
      # @return Fixnum
      def parse_base_16_digits(*digits)
        reduce(BASE_16_BIT_SHIFT, *digits)
      end

      # Treat each element as digits in base-2 positional notation
      # e.g. [1, 0, 1, 0] => 0b1010 = 10
      # @param Array<Fixnum> digits
      # @return Fixnum
      def parse_base_2_digits(*digits)
        reduce(BASE_2_BIT_SHIFT, *digits)
      end

      # Treat each element as digits in base-10 positional notation
      # i.e. [2, 7, 3, 5] = (2 x 10^3) + (7 x 10^2) + (3 x 10^1) + (5 x 10^0)
      # Example: [2, 7, 3, 5] => [2000, 700, 30, 5] => 2735
      # @param Array<Fixnum> digits
      # @return Fixnum
      def parse_base_10_digits(*digits)
        digits.reverse.map.with_index do |digit, index|
          digit * (BASE_10**index)
        end&.reduce(&:+)
      end

      alias base256 parse_base_256_digits
      alias base16  parse_base_16_digits
      alias base2   parse_base_2_digits
      alias base10  parse_base_10_digits

      # NUMBER TO DIGITS

      # Split number into base-256 positional notation digits
      # base-256 represents 1 byte, or 8 bits => 2^8 = 256
      # Example: 0x2706 => [0x27, 0x06]
      # @param Fixnum number
      # @return Array<Fixnum>
      def base_256_digits(number)
        binary_base_digits(BASE_256_BIT_SHIFT, number)
      end

      # NOTE: base 16 is required for GPS coordinates,and time which
      # are transmitted as base 16. A byte is used to represent two
      # base 10 numbers (a nibble each).
      # i.e. 145° is transmitted as bytes [0x01, 0x45]
      # The returned digits are then parsed as base 10.
      # e.g. [0x01, 0x45] => [0x1, 0x4, 0x5] => 145

      # Split number into base-16 positional notation digits
      # base-16 represents 1 nibble, or 4 bits => 2^4 = 16
      # Example: 0x2706 => [0x2, 0x7, 0x0, 0x6]
      def base_16_digits(number)
        binary_base_digits(BASE_16_BIT_SHIFT, number)
      end

      # Split number into base-2 positional notation digits
      # base-2 represents 1 bit => 2^1 => 2
      # Example: 0x83 => [1, 0, 0, 0, 0, 0, 1, 1]
      # @param Fixnum number
      # @return Array<Fixnum>
      def base_2_digits(number)
        binary_base_digits(BASE_2_BIT_SHIFT, number)
      end

      private

      def reduce(shift_size, *digits)
        digits.reduce(0) { |m, o| (m << shift_size) + o }
      end

      # Split number into base-256 positional notation digits
      # Example: 0x2706 => [0x27, 0x06]
      def binary_base_digits(bit_length, number)
        base = BASE_2**bit_length
        digits = []
        while number.positive?
          i = number.modulo(base)
          digits.unshift(i)
          number >>= bit_length
        end
        digits
      end
    end
  end
end
