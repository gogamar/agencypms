class Bed < ApplicationRecord
  belongs_to :bedroom
  BED_TYPES = {
    BED_BUNK: 2,
    BED_CHILD: 1,
    BED_CRIB: 1,
    BED_DOUBLE: 2,
    BED_KING: 2,
    BED_MURPHY: 1,
    BED_QUEEN: 2,
    BED_SOFA: 2,
    BED_SINGLE: 1,
    BED_FUTON: 1,
    BED_FLOORMATTRESS: 1,
    BED_TODDLER: 1,
    BED_HAMMOCK: 1,
    BED_AIRMATTRESS: 1,
    BED_COUCH: 1
  }
end
