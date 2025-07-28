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
    echo "  -b, --base COMMIT      Base commit/branch để so sánh (mặc định: main)"
    echo "  -l, --max-lines NUM    Số dòng tối đa mỗi part (mặc định: 300)"
    echo "  -o, --output DIR       Thư mục output (mặc định: diff_parts)"
    echo "  -e, --exclude PATTERN  Pattern để exclude thêm (mặc định: *Migration*)"
    echo "  -h, --help            Hiển thị help"
    echo ""
    echo "Ví dụ:"
    echo "  $0 feature/new-feature                           # So sánh với main"
    echo "  $0 feature/new-feature -b develop                # So sánh với develop"
    echo "  $0 HEAD -b HEAD~5                               # So sánh HEAD với 5 commit trước"
    echo "  $0 feature/new-feature -b abc123                # So sánh với commit abc123"
    echo "  $0 develop -l 200 -b main -e '*Migration*,*Test*'"
    echo ""
    echo "Lưu ý:"
    echo "  - BASE có thể là branch name, commit hash, hoặc reference như HEAD~N"
    echo "  - Nếu không chỉ định -b, sẽ so sánh với main branch"
}

# Mặc định values
BRANCH_NAME=""
BASE_COMMIT="main"
MAX_LINES=300
OUTPUT_DIR="diff_parts"
EXCLUDE_PATTERN="*Migration*"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -b|--base)
            BASE_COMMIT="$2"
            shift 2
            ;;
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
    echo -e "${RED}❌ Lỗi: Vui lòng cung cấp tên branch/commit${NC}"
    show_help
    exit 1
fi

# Kiểm tra nếu branch/commit tồn tại
if ! git rev-parse --verify "$BRANCH_NAME" >/dev/null 2>&1; then
    echo -e "${RED}❌ Lỗi: Branch/commit '$BRANCH_NAME' không tồn tại${NC}"
    echo -e "${YELLOW}💡 Các branch có sẵn:${NC}"
    git branch -a
    exit 1
fi

# Kiểm tra nếu base commit tồn tại
if ! git rev-parse --verify "$BASE_COMMIT" >/dev/null 2>&1; then
    echo -e "${RED}❌ Lỗi: Base commit/branch '$BASE_COMMIT' không tồn tại${NC}"
    echo -e "${YELLOW}💡 Các branch có sẵn:${NC}"
    git branch -a
    exit 1
fi

# Lấy commit hash để hiển thị rõ ràng hơn
BRANCH_HASH=$(git rev-parse --short "$BRANCH_NAME")
BASE_HASH=$(git rev-parse --short "$BASE_COMMIT")

FULL_DIFF_FILE="diff_${BASE_HASH}_to_${BRANCH_HASH}_$(date +%Y%m%d_%H%M%S).txt"

echo -e "${BLUE}🔍 So sánh từ: ${GREEN}$BASE_COMMIT${NC} ${YELLOW}($BASE_HASH)${NC}"
echo -e "${BLUE}         đến: ${GREEN}$BRANCH_NAME${NC} ${YELLOW}($BRANCH_HASH)${NC}"
echo -e "${BLUE}📏 Giới hạn lines mỗi part: ${GREEN}$MAX_LINES${NC}"
echo -e "${BLUE}📁 Thư mục output: ${GREEN}$OUTPUT_DIR${NC}"
echo -e "${BLUE}🚫 Exclude pattern: ${GREEN}$EXCLUDE_PATTERN${NC}"

# Tạo full diff với base commit được chỉ định
echo -e "${YELLOW}⏳ Đang tạo diff...${NC}"
git diff "$BASE_COMMIT"..."$BRANCH_NAME" -- . ":(exclude)$EXCLUDE_PATTERN" > $FULL_DIFF_FILE

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Lỗi: Không thể tạo diff${NC}"
    exit 1
fi

TOTAL_LINES=$(wc -l < $FULL_DIFF_FILE)
echo -e "${BLUE}📊 Tổng số dòng trong diff: ${GREEN}$TOTAL_LINES${NC}"

if [ $TOTAL_LINES -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Không có thay đổi nào được tìm thấy giữa $BASE_COMMIT và $BRANCH_NAME${NC}"
    rm $FULL_DIFF_FILE
    exit 0
fi

# Hiển thị summary về files đã thay đổi
echo -e "${BLUE}📋 Files thay đổi:${NC}"
git diff --name-only "$BASE_COMMIT"..."$BRANCH_NAME" -- . ":(exclude)$EXCLUDE_PATTERN" | head -10
CHANGED_FILES_COUNT=$(git diff --name-only "$BASE_COMMIT"..."$BRANCH_NAME" -- . ":(exclude)$EXCLUDE_PATTERN" | wc -l)
if [ $CHANGED_FILES_COUNT -gt 10 ]; then
    echo -e "${YELLOW}   ... và $((CHANGED_FILES_COUNT - 10)) files khác${NC}"
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
    
    # Đổi tên các file thành .txt và đánh số
    PART_NUM=1
    for file in $OUTPUT_DIR/diff_part_*; do
        if [[ "$file" != *.txt ]]; then
            # Tạo tên file có format đẹp hơn
            NEW_NAME="$OUTPUT_DIR/diff_part_$(printf "%02d" $PART_NUM)_${BASE_HASH}_to_${BRANCH_HASH}.txt"
            mv "$file" "$NEW_NAME"
            PART_NUM=$((PART_NUM + 1))
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
    
    # Xóa file diff gốc vì đã chia nhỏ
    rm $FULL_DIFF_FILE
    echo -e "${BLUE}🗑️  Đã xóa file diff gốc (đã chia nhỏ)${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Hoàn thành!${NC}"

# Hiển thị thống kê nhanh
echo -e "${BLUE}📈 Thống kê:${NC}"
echo -e "   ${YELLOW}Files thay đổi:${NC} $CHANGED_FILES_COUNT"
echo -e "   ${YELLOW}Tổng dòng diff:${NC} $TOTAL_LINES"
if [ $TOTAL_LINES -gt $MAX_LINES ]; then
    echo -e "   ${YELLOW}Số parts:${NC} $PART_COUNT"
fi
