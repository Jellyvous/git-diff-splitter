#!/bin/bash
# split_diff_advanced.sh

# Màu sắc cho output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function hiển thị help
show_help() {
    echo -e "${BLUE}📖 Git Diff Splitter Tool${NC}"
    echo ""
    echo "Cách sử dụng: $0 <branch-name> [options]"
    echo ""
    echo "Options:"
    echo "  -l, --max-lines NUM    Số dòng tối đa mỗi part (mặc định: 300)"
    echo "  -o, --output DIR       Thư mục output (mặc định: diff_parts)"
    echo "  -e, --exclude PATTERN  Pattern để exclude thêm (mặc định: *Migration*)"
    echo "  -h, --help            Hiển thị help"
    echo ""
    echo "Ví dụ:"
    echo "  $0 feature/new-feature"
    echo "  $0 feature/new-feature -l 500 -o my_diff_parts"
    echo "  $0 develop -l 200 -e '*Migration*,*Test*'"
}

# Mặc định values
BRANCH_NAME=""
MAX_LINES=300
OUTPUT_DIR="diff_parts"
EXCLUDE_PATTERN="*Migration*"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -l|--max-lines)
            MAX_LINES="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -e|--exclude)
            EXCLUDE_PATTERN="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        -*)
            echo -e "${RED}❌ Unknown option $1${NC}"
            show_help
            exit 1
            ;;
        *)
            if [ -z "$BRANCH_NAME" ]; then
                BRANCH_NAME="$1"
            else
                echo -e "${RED}❌ Too many arguments${NC}"
                show_help
                exit 1
            fi
            shift
            ;;
    esac
done

# Kiểm tra branch name
if [ -z "$BRANCH_NAME" ]; then
    echo -e "${RED}❌ Lỗi: Vui lòng cung cấp tên branch${NC}"
    show_help
    exit 1
fi

# Kiểm tra nếu branch tồn tại
if ! git rev-parse --verify "$BRANCH_NAME" >/dev/null 2>&1; then
    echo -e "${RED}❌ Lỗi: Branch '$BRANCH_NAME' không tồn tại${NC}"
    echo -e "${YELLOW}💡 Các branch có sẵn:${NC}"
    git branch -a
    exit 1
fi

FULL_DIFF_FILE="full_diff_$(date +%Y%m%d_%H%M%S).txt"

echo -e "${BLUE}🔍 Đang tạo diff cho branch: ${GREEN}$BRANCH_NAME${NC}"
echo -e "${BLUE}📏 Giới hạn lines mỗi part: ${GREEN}$MAX_LINES${NC}"
echo -e "${BLUE}📁 Thư mục output: ${GREEN}$OUTPUT_DIR${NC}"

# Tạo full diff với exclude pattern
git diff main...$BRANCH_NAME -- . ":(exclude)$EXCLUDE_PATTERN" > $FULL_DIFF_FILE

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Lỗi: Không thể tạo diff${NC}"
    exit 1
fi

TOTAL_LINES=$(wc -l < $FULL_DIFF_FILE)
echo -e "${BLUE}📊 Tổng số dòng trong diff: ${GREEN}$TOTAL_LINES${NC}"

if [ $TOTAL_LINES -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Không có thay đổi nào được tìm thấy${NC}"
    rm $FULL_DIFF_FILE
    exit 0
fi

if [ $TOTAL_LINES -le $MAX_LINES ]; then
    echo -e "${GREEN}✅ Diff nhỏ hơn $MAX_LINES dòng, không cần chia nhỏ${NC}"
    echo -e "${BLUE}📄 File diff: ${GREEN}$FULL_DIFF_FILE${NC}"
else
    echo -e "${YELLOW}📦 Diff quá lớn, đang chia thành các part...${NC}"
    
    mkdir -p $OUTPUT_DIR
    rm -f $OUTPUT_DIR/diff_part_*.txt
    
    # Chia file với prefix có ý nghĩa và extension .txt
    split -l $MAX_LINES $FULL_DIFF_FILE $OUTPUT_DIR/diff_part_
    
    # Đổi tên các file thành .txt
    PART_NUM=1
    for file in $OUTPUT_DIR/diff_part_*; do
        if [[ "$file" != *.txt ]]; then
            mv "$file" "${file}.txt"
        fi
    done
    
    PART_COUNT=$(ls $OUTPUT_DIR/diff_part_*.txt | wc -l)
    
    echo -e "${GREEN}✅ Đã chia thành $PART_COUNT parts${NC}"
    echo ""
    echo -e "${BLUE}📋 Danh sách parts:${NC}"
    
    PART_NUM=1
    for file in $OUTPUT_DIR/diff_part_*.txt; do
        LINES_IN_PART=$(wc -l < "$file")
        echo -e "   ${GREEN}📄 Part $PART_NUM:${NC} $(basename "$file") (${YELLOW}$LINES_IN_PART dòng${NC})"
        PART_NUM=$((PART_NUM + 1))
    done
fi

echo -e "${GREEN}🎉 Hoàn thành!${NC}"
